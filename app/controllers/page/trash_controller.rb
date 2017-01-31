class Page::TrashController < Page::SidebarsController

  guard :may_admin_page?
  helper 'page/trash'
  track_actions :update

  # loads popup
  def edit
  end

  def update
    if %w/delete destroy undelete/.include? params[:type]
      @page.public_send params[:type]
    else
      raise_error 'unknown type'
    end
  end

  protected

  def track_action
    super "#{params[:type]}_page"
  end

  def redirect_url
    if params[:type] == 'undelete'
      page_url(@page)
    else
      new_url
    end
  end
  helper_method :redirect_url

  def new_url
    if @page.owner and @page.owner != current_user
      entity_url @page.owner
    else
      me_url
    end
  end
  helper_method :new_url

end

