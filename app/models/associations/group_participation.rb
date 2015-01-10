=begin
a GroupParticipation holds the data representing a group's
relationship with a particular page.

create_table "group_participations", :force => true do |t|
  t.integer  "group_id",          :limit => 11
  t.integer  "page_id",           :limit => 11
  t.integer  "access",            :limit => 11
  t.boolean  "static",                          :default => false
  t.datetime "static_expires"
  t.boolean  "static_expired",                  :default => false
  t.integer  "featured_position", :limit => 11
end

add_index "group_participations", ["group_id", "page_id"], :name => "index_group_participations"
=end

class GroupParticipation < ActiveRecord::Base
  # this includes the ability to find featured-pages in GroupParticipation
  # include GroupParticipationExtension::Featured
  include GroupParticipationExtension::PageHistory
  include ParticipationAccess

  belongs_to :page, inverse_of: :group_participations
  belongs_to :group, inverse_of: :participations

  validates :page, presence: true
  validates :group, presence: true


  def entity
    group
  end

end
