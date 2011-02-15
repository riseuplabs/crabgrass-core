#
# All the controllers that have sidebar and popup controls inherit from
# this controller.
#
class Pages::SidebarController < Pages::BaseController

  layout nil
  
  protected
  
  def close_popup
    render :template => 'pages/sidebar/reset'
  end
  
end
