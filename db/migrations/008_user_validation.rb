Sequel.migration do
  up do
    alter_table :user do
      add_column :activation_token, String
      add_column :active, FalseClass, :default => false
    end
  end
  down do
    alter_table :user do
      drop_column :activation_token
      drop_column :active
    end
  end
end
