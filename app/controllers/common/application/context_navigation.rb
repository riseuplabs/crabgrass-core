#
# methods and helpers for context and navigation that should
# be available in all controllers.
#

module Common::Application::ContextNavigation


  def self.included(base)
    base.class_eval do
      helper_method :setup_navigation
    end
  end

  protected

  ##
  ## OVERRIDE
  ##

  def setup_navigation(nav)
    return nav
    # this can be implemented by controller subclasses
  end

end
