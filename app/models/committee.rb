class Committee < Group

  ##
  ## NAMING
  ##

  # the name of a committee includes the name of the parent,
  # so the committee names are unique. however, for display purposes
  # we want to just display the committee name without the parent name.

  # parent name + committee name
  def full_name
    read_attribute(:name)
  end
  # committee name without parent
  def short_name
    (read_attribute(:name)||'').sub(/^.*\+/,'')
  end

  # what we show to the user
  def display_name
    if read_attribute(:full_name).any?
      read_attribute(:full_name)
    else
      short_name
    end
  end

  # called when the parent's name has change
  def parent_name_changed
    self.name = short_name
  end

  # committees clean up their names a little different to make sure the group's
  # name is part of the committee's name.
  def clean_names
    super
    t_name = read_attribute(:name)
    return unless t_name
    if parent
      name_without_parent = t_name.sub(/^#{parent.name}\+/,'').gsub('+','-')
      write_attribute(:name, parent.name + '+' + name_without_parent)
    else
      write_attribute(:name, t_name.gsub('+','-'))
    end
  end

  ##
  ## PERMISSIONS
  ##

  # admin rights are restricted to members of the parents council if it exists
  # everything else can be accessed by members of the committee itself or its
  # parent group.
  # This saves us a lot of syncing of committee permissions when a groups
  # council changes.

  def has_access?(access, user=User.current)
    if access == :admin and parent.real_council
      parent.has_access?(:admin, user)
    else
      super
    end
  end

  ##
  ## ORGANIZATIONAL
  ##

  private

  before_destroy :remove_from_parent
  def remove_from_parent
    parent.remove_committee!(self)
    true
  end

  def parent=(p)
    raise 'call group.add_committee! instead'
  end

end
