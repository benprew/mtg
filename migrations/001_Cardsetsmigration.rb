class CreateCardsets < Sequel::Migration

  def up
    alter_table(:cards) do
      add_foreign_key(:cardset_id, :cardsets)
    end

    create_table(:cardsets) do
      primary_key :id
      String :name, :unique => true
      String :cardset_import_id, :unique => true
      Date :release_date
    end
  end

  def down
    drop_table(:cardsets)

    alter_table(:cards) do
      drop_column(:cardset_id)
    end
  end
end
