class Pages::DetailsController < Pages::SidebarsController

  before_filter :login_required

  # participation and share helpers can be removed if the corresponding
  # tabs end up getting removed from the details popup.
  helper 'pages/owner', 'pages/participation', 'pages/share'

  def show
  end

end

