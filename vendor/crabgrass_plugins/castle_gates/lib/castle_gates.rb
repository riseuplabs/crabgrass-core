
module CastleGates
  class LockError < StandardError
  end
  mattr_accessor :exception_class
  self.exception_class = LockError

  #
  # This is a big hack to get around the horrible way that rails unloads everything in development mode.
  #
  # In typical development mode, without rails-dev-boost enabled, rails unloads every model after
  # every request. It does this so that it can autoload models any time you reference the model anywhere.
  #
  # The problem is that once the model is unloaded, it no longer has acts_as_castle.
  # So, we need to re-apply the permission definitions in dev mode. We do this by making the permissions
  # defined in a class that we then set to be autoloadable, and we ensure it gets loaded on every request.
  #
  # For example:
  #
  #   CasteGates.initialize('config/permissions')
  #
  # RAILS3_TODO
  #
  # In rails 3:
  #   * ActionController::Dispatcher.to_prepare is changed to ActionDispatch::Callbacks.to_prepare.
  #   * autoload is moved to ActiveSupport::Autoload
  #
  def self.initialize(path)
    file_name  = File.basename(path)  # e.g. 'permissions'
    class_name = file_name.camelcase  # e.g. 'Permissions'

    #
    # require the permission definition file (this is only useful for testing mode)
    #
    require "#{Rails.root}/#{path}"

    #
    # make the class where permissions are defined (e.g. Permissions) autoloadable:
    #
    ActiveSupport::Dependencies.autoload_paths << "#{Rails.root}/#{File.dirname(path)}"
    ActiveSupport::Dependencies.explicitly_unloadable_constants << class_name

    #
    # Trigger autoload of Permissions class
    #
    ActionController::Dispatcher.to_prepare do
      # everything in this block is run at the start of every request.
      Kernel.const_get(class_name)
    end
  end

end

module CastleGates
  class Permissions
    def self.define(&block)
      self.instance_eval(&block)
    end

    def self.castle(model_class, &block)
      model_class.send(:acts_as_castle)
      model_class.class_eval(&block)
    end

    def self.holder(*args, &block)
      Holder::add_holder(*args, &block)
    end

    def self.holder_alias(name, options)
      Holder::add_holder_alias(name, options[:model])
    end
  end
end

libraries = ['key', 'gate', 'gate_set', 'acts_as_castle', 'holder_definition', 'holder', 'acts_as_holder', 'associations']
libraries.each do |file|
  require "#{File.dirname(__FILE__)}/castle_gates/#{file}"
end
