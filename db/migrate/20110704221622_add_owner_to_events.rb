class AddOwnerToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :owner_code, :integer
  end

  def self.down
    remove_column :events, :owner_code
  end
end
