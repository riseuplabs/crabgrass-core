module ActiveSupport::Dependencies
  unless ActiveSupport::Dependencies.method_defined? :autoload_paths
    alias_method :autoload_paths, :load_paths
    alias_method :autoload_paths=, :load_paths=
    alias_method :autoload_once_paths, :load_once_paths
    alias_method :autoload_once_paths=, :load_once_paths=
  end
end
