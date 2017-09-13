class Notice < ActiveRecord::Base
  belongs_to :user
  belongs_to :noticable, polymorphic: true
  belongs_to :avatar

  serialize :data

  validates :redirect_object, presence: true

  ##
  ## CLASS METHODS
  ##

  def self.for_user(user)
    where(user_id: user)
  end

  def self.for_noticable(noticable)
    where(noticable_id: noticable, noticable_type: type_field(noticable))
  end

  def self.dismissed(boolean)
    where(dismissed: boolean)
  end

  def self.find_all_by_noticable(noticable)
    for_noticable(noticable).all
  end

  def self.destroy_all_by_noticable(noticable)
    destroy_all(noticable_id: noticable.id, noticable_type: type_field(noticable))
  end

  def self.dismiss_all
    where(dismissed: false).update_all dismissed: true, dismissed_at: Time.now
  end

  def initialize(*args)
    super
    self.data ||= {}
  end

  ##
  ## INSTANCE METHODS
  ##

  def dismiss!
    self.dismissed = true
    self.dismissed_at = Time.now
    save!
  end

  ##
  ## PROBABLY OVERRIDDEN BY SUBCLASSES
  ##

  def display_title
    display_attr(:title)
  end

  def display_body
    display_attr(:body)
  end

  def display_label
    :notice.t
  end

  def display_body_as_quote?
    false
  end

  #
  # should return the symbol for the path method to redirect to.
  # slightly dubious use of putting view code in the model, but makes things much easier.
  #
  def redirect_path; end

  # object to hand to redirect path, defaults to noticable
  def redirect_object
    noticable
  end

  private

  #
  # currently, ActiveRecord::Base.store_full_sti_class is set to FALSE.
  # so, this means we need to search on the base_class, not the class.
  #
  # (there is an exception to this, if self.abstract_class = true for a
  # class, but i don't think we currently do this anywhere.)
  #
  def self.type_field(obj)
    if store_full_sti_class
      obj.class.name
    else
      obj.class.base_class.name
    end
  end

  def display_attr(attr)
    if data[attr].is_a? Array
      I18n.t(*data[attr])
    else
      I18n.t(data[attr], count: 1)
    end
  rescue
    Rails.logger.error "Invalid attribute #{attr} in Notice ##{id}."
    Rails.logger.debug 'value: ' + data[attr].inspect
    raise
  end
end
