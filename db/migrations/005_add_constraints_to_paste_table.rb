Sequel.migration do
  up do
    alter_table :paste_content do
      set_column_not_null :digest
      set_column_not_null :content
      set_column_not_null :created_at
    end

    alter_table :paste do
      set_column_not_null :ip_addr
      set_column_not_null :highlight
      set_column_not_null :active
      set_column_not_null :spam
      set_column_not_null :created_at
    end
  end
  down do
    alter_table :paste_content do
      set_column_allow_null :digest
      set_column_allow_null :content
      set_column_allow_null :created_at
    end

    alter_table :paste do
      set_column_allow_null :ip_addr
      set_column_allow_null :highlight
      set_column_allow_null :active
      set_column_allow_null :spam
      set_column_allow_null :created_at
    end
  end
end
