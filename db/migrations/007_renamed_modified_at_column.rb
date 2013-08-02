Sequel.migration do
  up do
    alter_table :paste do
      rename_column :modified_at, :updated_at
    end

    alter_table :paste_content do
      rename_column :modified_at, :updated_at
    end
  end
  down do
    alter_table :paste do
      rename_column :updated_at, :modified_at
    end

    alter_table :paste_content do
      rename_column :updated_at, :modified_at
    end
  end
end
