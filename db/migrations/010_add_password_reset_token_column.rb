Sequel.migration do
  up do
    alter_table :user do
      add_column :password_reset_token, String, :unique => true
      add_column :password_reset_token_generated_at, DateTime
    end
  end
  down do
    alter_table :user do
      drop_column :password_reset_token
      drop_column :password_reset_token_generated_at
    end
  end
end
