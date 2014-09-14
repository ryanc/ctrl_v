Sequel.migration do
  up do
    alter_table :security_log do
      add_column :user_agent, String
    end
  end
  down do
    alter_table :security_log do
      drop_column :user_agent
    end
  end
end
