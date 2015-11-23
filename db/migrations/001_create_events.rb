Sequel.migration do
  change do
    create_table(:events) do
      primary_key :id
      Integer :telegram_id
      json :content
    end
  end
end
