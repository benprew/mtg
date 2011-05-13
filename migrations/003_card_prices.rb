class CardPrices < Sequel::Migration
  def up
    alter_table(:card_prices) do
      add_column :volume, Integer
    end
  end
  
  def down
    alter_table(:card_prices) do
      drop_column :volume
    end
  end
end
