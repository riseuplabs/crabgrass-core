class Me::RecentPagesController < Me::BaseController
  def index
    render :update do |page|
      page.replace_html 'recent_pages_dropdown', :partial => 'common/pages/list',
        :locals => {:style => 'mini', :pages => current_user.pages.recent_pages}
    end
  end
end
