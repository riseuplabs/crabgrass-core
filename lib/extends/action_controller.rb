require 'action_controller'

ActionController::Base.class_eval do

  #
  # methods to help load our core extensions to ActionController::Base
  # Rails.root is not loaded yet when these are called, so we use __FILE__
  #

  def self.include_extensions(glob_path)
    path = File.dirname(__FILE__) + '/../../' + glob_path
    Dir.glob(path).each do |file|
      dirname  = File.basename(File.dirname(file))
      basename = File.basename(file).chomp('.rb')
      require("#{dirname}/#{basename}")
      include("#{dirname}/#{basename}".camelize.constantize)
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
