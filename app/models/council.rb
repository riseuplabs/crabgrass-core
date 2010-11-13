class Council < Committee

  after_create :alter_parent_permissions
  def alter_parent_permissions
    parent.allow! self, :all
    parent.disallow! parent, :admin
  end


end

