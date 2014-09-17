=begin

=end

class ProfileEmailAddress < ActiveRecord::Base

  set_table_name 'email_addresses'

  validates_presence_of :email_type
  validates :email_address, :presence => true
  # :email_format => true

  belongs_to :profile, :class_name => 'Profile', :foreign_key => 'profile_id'

  after_save {|record| record.profile.save if record.profile}
  after_destroy {|record| record.profile.save if record.profile}

  def self.options
    [:Home, :Work, :School, :Personal, :Group, :Other].to_localized_select
  end

  def icon
    'page_message'
  end
end
