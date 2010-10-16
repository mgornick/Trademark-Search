class CreateTrademarks < ActiveRecord::Migration
  def self.up
    create_table :trademarks do |t|
      t.string :term
      t.boolean :complete
      t.text :bing_search_page
      t.text :google_search_page
      t.text :yahoo_search_page
      t.integer :total_google_results
      t.integer :total_yahoo_results
      t.integer :total_bing_results

      t.timestamps
    end
  end

  def self.down
    drop_table :trademarks
  end
end
