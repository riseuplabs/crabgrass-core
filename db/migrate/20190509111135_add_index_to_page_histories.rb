class AddIndexToPageHistories < ActiveRecord::Migration
  def change
    add_index "page_histories", ["notification_digest_sent_at"]
  end
end
