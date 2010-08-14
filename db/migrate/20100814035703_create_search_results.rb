class CreateSearchResults < ActiveRecord::Migration
  def self.up
    create_table :search_results do |t|
      t.string :url
      t.string :search_engine

      t.timestamps
    end
  end

  def self.down
    drop_table :search_results
  end
end
