Sequel.migration do
  up do
    create_table :paste_content do
      primary_key :id
      String :digest
      DateTime :created_at, :default => Sequel.lit("CURRENT_TIMESTAMP")
      DateTime :modified_at
      Text :content
    end

    create_table :paste do
      primary_key :id
      foreign_key :content_id, :paste_content
      foreign_key :user_id, :user
      String :id_b62
      String :filename
      Boolean :highlight, :default => true
      String :ip_addr
      Boolean :is_active, :default => true
      DateTime :created_at, :default => Sequel.lit("CURRENT_TIMESTAMP")
      DateTime :modified_at
    end
  end
  down do
    drop_table :paste
    drop_table :paste_content
  end
end
