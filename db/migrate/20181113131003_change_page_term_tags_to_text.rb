class ChangePageTermTagsToText < ActiveRecord::Migration
  def change
    change_column :page_terms, :tags, :text
  end
end
