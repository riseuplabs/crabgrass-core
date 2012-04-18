class Council < Committee

  def destroy_by(user)
    self.parent.grant! self.parent, :admin
    super
  end

end

