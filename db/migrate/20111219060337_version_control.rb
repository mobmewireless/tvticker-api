class VersionControl < ActiveRecord::Migration
  def self.up

    create_table :versions do |t|
      t.string :number
      t.timestamps
    end

    add_column :categories, :version_id, :string
    add_column :channels, :version_id, :string
    add_column :programs, :version_id, :string
    add_column :series, :version_id, :string
    add_column :thumbnails, :version_id, :string

    add_index :versions, :number, :unique
    add_index :categories, :version_id
    add_index :channels, :version_id
    add_index :programs, :version_id
    add_index :series, :version_id
    add_index :thumbnails, :version_id

  end

  def self.down

    remove_index :versions, :number
    remove_index :categories, :version_id
    remove_index :channels, :version_id
    remove_index :programs, :version_id
    remove_index :series, :version_id
    remove_index :thumbnails, :version_id

    remove_column :categories, :version_id, :string
    remove_column :channels, :version_id, :string
    remove_column :programs, :version_id, :string
    remove_column :series, :version_id, :string
    remove_column :thumbnails, :version_id, :string

    drop_table version
    raise ActiveRecord::IrreversibleMigration
  end
end
