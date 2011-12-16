class Series < ActiveRecord::Migration
  def self.up
    create_table :series do |t|
      t.string :name
      t.text :imdb_info
      t.text :description
      t.text :thumbnail_link
      t.string :rating
      t.timestamps
    end
  end

  def self.down
    drop_table   :series
    raise ActiveRecord::IrreversibleMigration
  end
end
