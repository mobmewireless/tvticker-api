class Program < ActiveRecord::Migration
  def self.up
    create_table :programs do |t|
      t.string :name
      t.integer :category_id
      t.integer :series_id
      t.integer :channel_id
      t.datetime :air_time_start
      t.datetime :air_time_end
      t.datetime :run_time
      t.text :imdb_info
      t.text :description
      t.text :thumbnail_link
      t.string :rating
      t.timestamps
    end
  end

  def self.down
    drop_table   :programs
    raise ActiveRecord::IrreversibleMigration
  end
end
