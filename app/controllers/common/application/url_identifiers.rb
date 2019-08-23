#
# These are used in order to help make it easier to decide which
# thing is selected (for example, when showing navigation lists)
#
# for example:
#
#   active = controller?(:requests) and action?(:pending, :open)
#

module Common::Application::UrlIdentifiers
  def self.included(base)
    base.class_eval do
      helper_method :action?
      helper_method :controller?
      helper_method :page_controller?
    end
  end

  ##
  ## PARAMS COMPARISON
  ##

  protected

  #
  # returns true if params[:action] matches one of the args.
  #
  def action?(*actions)
    actions.detect do |action|
      if action.is_a? String
        action == action_string
      elsif action.is_a? Symbol
        if action == :none
          action_string.nil?
        else
          action == action_symbol
        end
      end
    end
  end

  # returns true if params[:controller] matches one of the args.
  # for example:
  #   controller?(:me, :home)
  #   controller?('groups/')  <-- matches any controller in namespace 'groups'
  def controller?(*controllers)
    controllers.each do |cntr|
      if cntr.is_a? String
        if cntr.ends_with?('/')
          return true if controller_string.starts_with?(cntr.chop)
        end
        return true if cntr == controller_string
      elsif cntr.is_a? Symbol
        return true if cntr == controller_symbol
      end
    end
    false
  end

  # return true if the current controller is page related.
  def page_controller?
    controller?('me/pages', 'groups/pages', 'people/pages', 'pages/') or controller.is_a?(Page::BaseController) or controller.is_a?(Page::CreateController)
  end

  private

  def controller_string
    @controller_string ||= params[:controller].to_s.gsub(/^\//, '')
  end

  def controller_symbol
    @controller_symbol ||= controller_string.tr('/', '_').to_sym
  end

  def action_string
    params[:action]
  end

  def action_symbol
    if params[:action].present?
      params[:action].to_sym
    else
      nil
    end
  end
end
