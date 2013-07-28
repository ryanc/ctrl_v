Sequel.migration do
  up do
    alter_table :paste do
      add_column :is_spam, FalseClass, :default => false
    end
  end
  down do
    alter_table :paste do
      drop_column :is_spam
    end
  end
end
