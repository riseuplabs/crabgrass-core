#
# this is something that should be available to all controllers and views.
# there is no real path for entities defined in routes.rb, but we would
# like to be able to pretend that there was one.
#

module ControllerExtension::EntityPath

  def self.included(base)
    base.class_eval do
      helper_method :entity_path
    end
  end

  protected

  def entity_path(entity)
    if entity.is_a? String
      "/"+name
    else
      "/"+entity.name
    end
  end

end

