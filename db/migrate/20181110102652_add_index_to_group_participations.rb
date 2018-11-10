#
# Getting group participations for a given page was slow.
# Let's speed it up.
#
class AddIndexToGroupParticipations < ActiveRecord::Migration
  def change
    add_index "group_participations", ["page_id"]
  end
end
