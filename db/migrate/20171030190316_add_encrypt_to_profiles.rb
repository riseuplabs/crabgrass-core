class AddEncryptToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :encrypt, :boolean, default: 0
  end
end
