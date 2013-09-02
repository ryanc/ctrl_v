Sequel.migration do
  up do
    alter_table :user do
      add_unique_constraint :activation_token
    end
  end
  down do
    alter_table :user do
      drop_constraint :user_activation_token_key
    end
  end
end
