Sequel.migration do
  up do
    alter_table :paste do
      rename_column :is_active, :active
      rename_column :is_spam, :spam
    end
  end
  down do
    alter_table :paste do
      rename_column :active, :is_active
      rename_column :spam, :is_spam
    end
  end
end
