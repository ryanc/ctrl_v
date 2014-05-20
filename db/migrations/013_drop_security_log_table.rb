Sequel.migration do
  up do
    drop_table :security_log
  end
  down do
    create_table :security_log do
      primary_key :id
      foreign_key :user_id, :user
      String :action, null: false
      String :note
      String :ip_addr, null: false
      String :user_agent, null: false
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
