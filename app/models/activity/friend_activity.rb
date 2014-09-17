class FriendActivity < Activity

  validates_format_of :subject_type, :with => /User/
  validates_format_of :item_type, :with => /User/
  validates_presence_of :subject_id
  validates_presence_of :item_id

  alias_attr :user,       :subject
  alias_attr :other_user, :item

  before_create :set_access
  def set_access
    # this has a weird side effect of creating public and private
    # profiles if they don't already exist.
    if user.access? :public => :see_contacts
      self.access = Activity::PUBLIC
    elsif user.access? user.associated(:friends) => :see_contacts
      self.access = Activity::DEFAULT
    else
      self.access = Activity::PRIVATE
    end
  end

  def description(view=nil)
    I18n.t(:activity_contact_created,
            :user => user_span(:user),
            :other_user => user_span(:other_user))
  end

  def self.find_twin(user, other_user)
    where(:subject_id => other_user, :subject_type => 'User').
      where(:item_id => user, :item_type => 'User').first
  end

  def icon
    'user_add'
  end

end

