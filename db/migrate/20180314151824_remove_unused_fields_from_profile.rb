class RemoveUnusedFieldsFromProfile < ActiveRecord::Migration
  def change
    remove_column :profiles, :name_prefix, :string
    remove_column :profiles, :name_suffix, :string
    remove_column :profiles, :nickname, :string
    remove_column :profiles, :birthday, :string
    remove_column :profiles, :may_see_committees, :boolean
    remove_column :profiles, :may_see_networks, :boolean
    remove_column :profiles, :may_see_members, :boolean
    remove_column :profiles, :may_see_contacts, :boolean
    remove_column :profiles, :may_see_groups, :boolean
    remove_column :profiles, :may_request_membership, :boolean
  end
end
