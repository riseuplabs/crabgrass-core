#
# Speed up retrieving notices for a given page.
# This is needed when destroying the page to remove the notices for example.
#

class AddIndexToNotices < ActiveRecord::Migration
  def change
    add_index "notices", ["noticable_type", "noticable_id"]
  end
end
