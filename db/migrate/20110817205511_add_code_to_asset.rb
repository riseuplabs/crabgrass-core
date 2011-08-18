class AddCodeToAsset < ActiveRecord::Migration
  def self.up
    add_column :assets, :code, :string
    add_column :asset_versions, :code, :string
  end

  def self.down
    remove_column :assets, :code
    remove_column :asset_versions, :code
  end
end
