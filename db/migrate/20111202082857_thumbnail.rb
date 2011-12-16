class Thumbnail < ActiveRecord::Migration
  def self.up
    create_table :thumbnails do |t|
      t.string :name
      t.text :original_link
      t.text :thumbnail_link
      t.string :image
      t.string :status
      t.timestamps
    end
  end

  def self.down
    drop_table :thumbnails
    raise ActiveRecord::IrreversibleMigration
  end
end
