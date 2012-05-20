class Pages::DetailsController < Pages::SidebarsController

  # participation and share helpers can be removed if the corresponding
  # tabs end up getting removed from the details popup.
  helper 'pages/owner', 'pages/participation', 'pages/share'

  def show
  end

end

