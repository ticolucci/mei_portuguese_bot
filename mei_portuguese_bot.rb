DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost:5432/mei_portuguese_bot')

BOT_TOKEN = ENV['BOT_TOKEN']
Events = DB[:events]
InterfaceChats = DB[:interface_chats]
Tokens = DB[:tokens]

def send_message(message)
  bot_api = Faraday.new(url: "https://api.telegram.org/bot#{BOT_TOKEN}/sendMessage")
  bot_api.post do |request|
    request.headers['Content-Type'] = 'application/json'
    request.body = message
  end
end

def get_new_token
  tokens_api = Faraday.new(url: "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13")
  response = tokens_api.post do |request|
    request.headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
    request.body = {
      client_id: ENV['CLIENT_ID'],
      client_secret: ENV['CLIENT_SECRET'],
      scope: 'http://api.microsofttranslator.com',
      grant_type: 'client_credentials'
    }
  end
  new_token = JSON.parse(response.body)
  if new_token['error']
    raise "[Error] generating token: #{new_token['error']}\n[Error] description: #{new_token['error_description']}"
  end
  new_token
end

def save_token(new_token)
  Tokens.delete
  Tokens.insert(
    expires_at: Time.now.to_i + new_token['expires_in'].to_i,
    value: new_token['access_token']
  )
end

def token
  last_token = Tokens.order(:expires_at).last
  puts "Last token:"
  p last_token
  if last_token && last_token[:expires_at] > Time.now.to_i + 10
    last_token[:value]
  else
    puts "creating new token"
    new_token = get_new_token
    save_token(new_token)
    new_token['access_token']
  end
end

def translate(message)
  translation_api = Faraday.new(url: "http://api.microsofttranslator.com/v2/Http.svc/Translate")
  puts "[INFO] requesting translation"
  response = translation_api.get do |request|
    request.headers['Authorization'] = "Bearer #{token}"
    request.params['from'] = 'pt'
    request.params['to'] = 'en'
    request.params['text'] = message
  end
  if response.status.to_i > 200 && response.body =~ /^<html>/
    p "[Error] translation api returned this:\n#{response.body}"
  else
    response.body =~ />([^<]+)</
    $1
  end
end

def register_chat chat_id
  if InterfaceChats.where(chat_id: chat_id)
    send_message({chat_id: chat_id, text: 'chat was already registered'}.to_json)
    puts "[Info] send_message({chat_id: #{chat_id}, text: #{'chat was already registered'}}.to_json)"
  else
    InterfaceChats.insert(chat_id: chat_id)
    send_message({chat_id: chat_id, text: 'chat registered successfully'}.to_json)
    puts "[Info] send_message({chat_id: #{chat_id}, text: #{'chat registered successfully'}}.to_json)"
  end
end

def unregister_chat chat_id
  if InterfaceChats.where(chat_id: chat_id)
    InterfaceChats.where(chat_id: chat_id).delete
    send_message({chat_id: chat_id, text: 'chat unregistered'}.to_json)
    puts "[Info] send_message({chat_id: #{chat_id}, text: #{'chat unregistered'}}.to_json)"
  else
    send_message({chat_id: chat_id, text: 'nothing to do here'}.to_json)
    puts "[Info] send_message({chat_id: #{chat_id}, text: #{'nothing to do here'}}.to_json)"
  end
end

def handle_message result
  return {already: 'processed'} if Events[telegram_id: result['update_id']]
  DB.transaction do
    message = result['message']
    case message['text']
    when '/start_mei_bot'
      # register_chat(message['chat']['id'])
    when '/end_mei_bot'
      # unregister_chat(message['chat']['id'])
    else
      Events.insert(telegram_id: result['update_id'], content: {message: message}.to_json)

      from  = message['from']
      translated_message = "#{from['first_name']} #{from['last_name']} (#{from['username']}) said:\n"
      translated_message << translate(message['text'])

      puts "[Info] going to publish message to #{InterfaceChats.count} telegram things"
      InterfaceChats.map(:chat_id).each do |chat_id|
        request = send_message({chat_id: chat_id, text: translated_message}.to_json)
        puts "[Info] send_message({chat_id: #{chat_id}, text: #{translated_message}}.to_json)"
      end
      { published_message: translated_message }
    end
  end
end

def process ping
  if ping.keys.include?('ok') && !ping['ok']
    if ping.keys.include?('error_code') && ping.keys.include?('description')
      puts "[Error] #{ping['error_code']}: #{ping['description']}"
      { error: :sorry }
    else
      { random: 'error' }
    end
  else
    handle_message ping
  end
end

post "/#{BOT_TOKEN}" do
  ping = JSON.parse request.body.read
  puts "[Info] received new message with keys: #{ping.keys.inspect}"
  p ping if ENV['DEBUG']

  json(process(ping))
end
