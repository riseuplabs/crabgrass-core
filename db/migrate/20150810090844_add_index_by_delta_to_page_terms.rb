class AddIndexByDeltaToPageTerms < ActiveRecord::Migration
  def change
    add_index :page_terms, :delta
  end
end
