class ChannelsTable < ActiveRecord::Migration
  def self.up
    create_table :channels do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :channels
    raise ActiveRecord::IrreversibleMigration
  end
end
