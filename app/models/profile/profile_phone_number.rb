#

class ProfilePhoneNumber < ActiveRecord::Base
  self.table_name = 'phone_numbers'

  validates_presence_of :phone_number_type
  validates_presence_of :phone_number

  belongs_to :profile, class_name: 'Profile', foreign_key: 'profile_id'

  after_save { |record| record.profile.save if record.profile }
  after_destroy { |record| record.profile.save if record.profile }

  def self.options
    %i[Home Fax Mobile Pager Work Other].to_localized_select
  end

  def icon
    case phone_number_type
    when 'Home'   then 'house'
    when 'Fax'    then 'fax'
    when 'Mobile' then 'mobile'
    when 'Pager'  then 'mobile'
    else 'phone'
    end
  end
end
