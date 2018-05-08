class RemoveViewsCountFromPages < ActiveRecord::Migration
  def change
    remove_column :pages, :views_count, :integer
  end
end
