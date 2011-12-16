class AlterProgramRunTimeToBigInt < ActiveRecord::Migration
  def self.up
    change_column :programs, :run_time, :bigint, :default=>0
  end

  def self.down
    change_column :programs, :run_time, :datetime
    raise ActiveRecord::IrreversibleMigration
  end
end
