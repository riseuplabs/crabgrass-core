require File.dirname(__FILE__) + '/lib/load_const_callback'
require File.dirname(__FILE__) + '/lib/callback_class_const_missing'
require File.dirname(__FILE__) + '/lib/after_reload'

Class.instance_eval  { include CallbackClassConstMissing }
Object.instance_eval { include AfterReload }
