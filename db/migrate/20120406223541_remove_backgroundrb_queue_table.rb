class RemoveBackgroundrbQueueTable < ActiveRecord::Migration
  def self.up
    drop_table :bdrb_job_queues
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
