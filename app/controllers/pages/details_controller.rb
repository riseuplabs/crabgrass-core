

class Pages::DetailsController < Pages::SidebarController

  before_filter :login_required

  helper 'pages/owner'
  
  def show
  end
  
end

