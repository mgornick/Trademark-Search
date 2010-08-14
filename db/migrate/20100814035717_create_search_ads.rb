class CreateSearchAds < ActiveRecord::Migration
  def self.up
    create_table :search_ads do |t|
      t.string :url
      t.string :search_engine
      t.string :location

      t.timestamps
    end
  end

  def self.down
    drop_table :search_ads
  end
end
