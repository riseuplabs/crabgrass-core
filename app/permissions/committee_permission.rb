module CommitteePermission

  protected

  # if called on a parent, then it return true if the subcommittees are visible.
  # otherwise, it returns true if the current committee is visible.
  def may_view_committee?(group = @group)
    return may_view_group?(group) if group.committee?
    group.has_access? :see_committees
  end

  [:show, :list].each do |action|
    alias_method "may_#{action}_committee?".to_sym, :may_view_committee?
  end

  def may_admin_committee?(group = @group)
    current_user.may?(:admin, group)
  end

  [:create, :destroy, :edit].each do |action|
    alias_method "may_#{action}_committee?".to_sym, :may_admin_committee?
  end

end
