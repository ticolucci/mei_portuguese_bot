DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost:5432/mei_portuguese_bot')

BOT_TOKEN = ENV['BOT_TOKEN']
Events = DB[:events]
InterfaceChats = DB[:interface_chats]
BOT = Faraday.new(url: "https://api.telegram.org/bot#{BOT_TOKEN}/")

def send_message(message)
  BOT.post do |request|
    request.url 'sendMessage'
    request.headers['Content-Type'] = 'application/json'
    request.body = message
  end
end

post "/#{BOT_TOKEN}" do
  ping = JSON.parse request.body.read
  if ping['ok']
    ping['result'].each do |result|
      next if Events[telegram_id: result['update_id']]
      DB.transaction do
        message = result['message']
        if message
          Events.insert(telegram_id: result['update_id'], content: {message: message}.to_json)

          from  = message['from']
          message_to_translate = "#{from['first_name']} #{from['last_name']} (#{from['username']}) disse:\n"
          message_to_translate << message['text']
          translated_message = translate(message_to_translate)

          InterfaceChats.map(:chat_id).each do |chat_id|
            # request = send_message({chat_id: chat_id, text: translated_message}.to_json)
            # puts "Info: #{JSON.parse(request.body).inspect}"
          end
          json({ published_message: translated_message })
        end
      end
    end
  else
    puts "Error: #{ping['error_code']}: #{ping['description']}"
    json(error: :sorry)
  end
end
