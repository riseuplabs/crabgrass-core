class Notice < ActiveRecord::Base

  belongs_to :user
  belongs_to :noticable
  belongs_to :avatar
  
  serialize :data

  def display_title
  end

  def display_body
  end

end
