class Page::TrashController < Page::SidebarsController
  track_actions :update

  # loads popup
  def edit
    authorize @page, :admin?
  end

  def update
    authorize @page, :admin?
    if %w[delete destroy undelete].include? params[:type]
      @page.public_send params[:type]
    else
      raise ErrorMessage, 'unknown type'
    end
  end

  def destroy
    authorize @page
    @page.destroy
    redirect_to me_home_path
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
