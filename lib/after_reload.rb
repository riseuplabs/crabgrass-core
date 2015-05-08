require 'after_reload/load_const_callback'
require 'after_reload/callback_class_const_missing'

#
# globally define an after_reload method
#
module AfterReload
  private
  def after_reload(const, &block)
    LoadConstCallback.add(const, &block)
  end
end

Class.instance_eval  { include CallbackClassConstMissing }
Object.instance_eval { include AfterReload }
