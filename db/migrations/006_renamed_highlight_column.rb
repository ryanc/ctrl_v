Sequel.migration do
  up do
    alter_table :paste do
      rename_column :highlight, :highlighted
    end
  end
  down do
    alter_table :paste do
      rename_column :highlighted, :highlight
    end
  end
end
