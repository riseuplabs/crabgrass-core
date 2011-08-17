require 'action_controller'

ActionController::Base.class_eval do

  #
  # methods to help load our core extensions to ActionController::Base
  # Rails.root is not loaded yet when these are called, so we use __FILE__
  #

  def self.include_controllers(include_path)
    root = File.dirname(__FILE__) + '/../..'
    prefix = "#{root}/app/controllers/"
    full_path = "#{prefix}#{include_path}"
    if File.directory?(full_path)
      file_paths = Dir.glob(full_path + '/*.rb').collect{|f|f.chomp('.rb')}
    else
      file_paths = [full_path]
    end
    file_paths.each do |file_path|
      relative_path = file_path.sub(/^#{Regexp.escape(prefix)}/, "")
      #require(relative_path)
      include(relative_path.camelize.constantize)
      ActiveSupport::Dependencies.explicitly_unloadable_constants << relative_path.camelize
    end
  end

  def self.include_helpers(glob_path)
    path = File.dirname(__FILE__) + '/../../' + glob_path
    Dir.glob(path).each do |file|
      dirname  = File.basename(File.dirname(file))
      basename = File.basename(file).chomp('_helper.rb')
      helper("common/#{dirname}/#{basename}")
    end
  end

end
