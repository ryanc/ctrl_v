Sequel.migration do
  up do
    create_table :security_log do
      primary_key :id
      foreign_key :user_id, :user
      String :action, :null => false
      String :note
      String :ip_addr, :null => false
      DateTime :created_at, :default => Sequel::CURRENT_TIMESTAMP
    end
  end
  down do
    drop_table :security_log
  end
end
