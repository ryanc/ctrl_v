Sequel.migration do
  up do
    from(:paste).where(active: false).delete()
    drop_column :paste, :active
  end
  down do
    add_column :paste, :active, TrueClass, default: true
  end
end
