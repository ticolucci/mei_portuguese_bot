Sequel.migration do
  change do
    create_table(:tokens) do
      primary_key :id
      Integer :expires_at
      String :value
    end
  end
end
