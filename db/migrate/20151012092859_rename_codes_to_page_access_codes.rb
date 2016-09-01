class RenameCodesToPageAccessCodes < ActiveRecord::Migration
  def change
    rename_table :codes, :page_access_codes
  end
end
