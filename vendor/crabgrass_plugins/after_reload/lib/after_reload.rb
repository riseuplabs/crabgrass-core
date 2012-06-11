#
# globally define an after_reload method
#
module AfterReload
  private
  def after_reload(const, &block)
    LoadConstCallback.add(const, &block)
  end
end
