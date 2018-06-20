class Page::DetailsController < Page::SidebarsController
  # participation and share helpers can be removed if the corresponding
  # tabs end up getting removed from the details popup.
  helper 'page/owner', 'page/participation', 'page/share'

  def show
    authorize @page
  end
end
