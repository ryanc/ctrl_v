Sequel.migration do
  up do
    drop_column :paste, :spam
  end
  down do
    add_column :paste, :spam, FalseClass, default: false
  end
end
