Sequel.migration do
  up do
    add_column :paste, :one_time, FalseClass, default: false
  end
  down do
    drop_column :paste, :one_time
  end
end
