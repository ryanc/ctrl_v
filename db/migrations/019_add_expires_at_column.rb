Sequel.migration do
  up do
    add_column :paste, :expires_at, DateTime
  end
  down do
    drop_column :paste, :expires_at
  end
end
