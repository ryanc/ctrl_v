Sequel.migration do
  change do
    add_column :paste, :view_count, Integer, default: 0
  end
end
