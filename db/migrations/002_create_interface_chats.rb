Sequel.migration do
  change do
    create_table(:interface_chats) do
      primary_key :id
      Integer :chat_id
    end
  end
end
