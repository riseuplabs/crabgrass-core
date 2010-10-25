
require 'active_record'
require 'action_controller'

ActiveRecord::Base.class_eval do
  def self.acts_as_path_findable
    extend PathFinder::FindByPath
  end
end

ActionController::Base.send(:include, PathFinder::ControllerExtension)

