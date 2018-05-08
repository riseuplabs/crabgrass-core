class RemoveViewsCountFromPageTerms < ActiveRecord::Migration
  def change
    remove_column :page_terms, :views_count, :integer
  end
end
