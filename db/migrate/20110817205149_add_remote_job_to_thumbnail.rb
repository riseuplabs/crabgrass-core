class AddRemoteJobToThumbnail < ActiveRecord::Migration
  def self.up
    add_column :thumbnails, :remote_job_id, :integer
  end

  def self.down
    remove_column :thumbnails, :remote_job_id
  end
end
