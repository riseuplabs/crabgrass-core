class Person::HomeController < Person::BaseController
  layout 'sidecolumn'

  #
  # called by DispatchController
  #
  def initialize(options = {})
    super()
    @user = options[:user]
  end
  hide_action :initialize

  def show
    authorize @user
    if current_user.may? :view, @user
      @profile = @user.profiles.public
      @pages = Page.paginate_by_path '/descending/updated_at/limit/30/',
        options_for_user(@user),
        pagination_params
    end
  end
end
