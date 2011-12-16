class Category < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :categories
    raise ActiveRecord::IrreversibleMigration
  end
end
