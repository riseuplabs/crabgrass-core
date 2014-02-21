class AddOwnerIdToPageTerms < ActiveRecord::Migration
  def self.up
    add_column :page_terms, :owner_id, :integer
  end

  def self.down
    remove_column :page_terms, :owner_id
  end
end
