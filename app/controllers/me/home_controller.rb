class Me::HomeController < Me::BaseController

  def index
    @notices = Notice.for_user(current_user)
                     .dismissed(params[:view] == 'old')
                     .includes(:noticable)
                     .order('created_at DESC')
                     .limit(5) # TODO: should this be configurable?

    @pages = Page.paginate_by_path '', options_for_me, pagination_params
  end

 end
