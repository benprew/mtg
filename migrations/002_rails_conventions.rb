class RailsConventions < Sequel::Migration
  def up
    alter_table(:cards) do
      rename_column :type, :card_type
    end
  end
  
  def down
    alter_table(:cards) do
      rename_column :card_type, :type
    end
  end
end
