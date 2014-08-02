Sequel.migration do
  up do
    add_column :paste, :content, String, text: true

    # Move paste content from the paste_content table into the paste table.
    from(:paste).update(content: from(:paste_content).
                                 where(paste_content__id: :paste__content_id).
                                 select(:content))

    drop_column :paste, :content_id
    drop_table :paste_content
  end
  down do
    create_table(:paste_content) do
      primary_key :id
      String :digest, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :content, :text=>true, :null=>false
    end
    add_foreign_key :paste_content, :content_id, :paste_content, :key=>[:id]
  end
end
