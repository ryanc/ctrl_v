Sequel.migration do
  up do
    create_table :user do
      primary_key :id
      String :name
      String :username, :null => false, :unique => true
      String :email, :null => false, :unique => true
      String :password_hash, :null => false
      DateTime :created_at, :default => Sequel.lit("CURRENT_TIMESTAMP")
      DateTime :last_seen_at
      DateTime :updated_at
    end
  end
  down do
    drop_table :user
  end
end
