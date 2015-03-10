class RemovePostsCountFromPages < ActiveRecord::Migration
  def change
    change_table :pages do |pages|
      pages.remove :posts_count
    end
  end
end
