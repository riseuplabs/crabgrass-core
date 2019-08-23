class AddIndexToPageHistories < ActiveRecord::Migration[4.2]
  def change
    add_index "page_histories", ["notification_digest_sent_at"]
  end
end
