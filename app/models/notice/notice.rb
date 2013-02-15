class Notice < ActiveRecord::Base

  belongs_to :user
  belongs_to :noticable, :polymorphic => true
  belongs_to :avatar

  serialize :data

  ##
  ## CLASS METHODS
  ##

  scope(:for_user, lambda {|user|
    {:conditions => {:user_id => user.id}}
  })

  scope(:for_noticable, lambda{|noticable|
    {:conditions => {:noticable_id => noticable.id, :noticable_type => type_field(noticable)}}
  })

  scope(:dismissed, lambda{|boolean|
    {:conditions => {:dismissed => boolean}}
  })

  def self.find_all_by_noticable(noticable)
    find(:all, :conditions => {:noticable_id => noticable.id, :noticable_type => type_field(noticable)})
  end

  def self.destroy_all_by_noticable(noticable)
    destroy_all(:noticable_id => noticable.id, :noticable_type => type_field(noticable))
  end

  #
  # marks all notices associated with the noticable as dismissed.
  #
  def self.dismiss_all(noticable)
    connection.execute(
      "UPDATE notices SET dismissed = 1 WHERE noticable_type = '%s' AND noticable_id = %s" %
      [type_field(noticable), noticable.id]
    )
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
  # should return the symbol for the path method for the noticable.
  # slightly dubious use of putting view code in the model, but makes things much easier.
  #
  def noticable_path
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
    if self.store_full_sti_class
      obj.class.name
    else
      obj.class.base_class.name
    end
  end

  def display_attr(attr)
    if data.is_a? Hash
      if data[attr].is_a? Array
        I18n.t(*data[attr])
      else
        I18n.t(data[attr])
      end
    end
  end

end
