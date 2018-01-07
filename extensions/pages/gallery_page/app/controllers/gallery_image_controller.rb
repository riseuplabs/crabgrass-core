class GalleryImageController < Page::BaseController
  helper 'gallery'

  # default_fetch_data is disabled for new in Pages::BaseController
  prepend_before_filter :fetch_page_for_new, only: :new

  def show
    authorize @page
    @showing = @page.showings.includes(:asset).find_by_asset_id(params[:id])
    @image = @showing.asset
    # position sometimes starts at 0 and sometimes at 1?
    @image_index = @page.images.index(@image).next
    @image_count = @page.showings.count
    @next = @showing.lower_item
    @previous = @showing.higher_item
  end

  # removed an non ajax fallback, azul
  def sort
    authorize @page, :edit?
    @page.sort_images params[:assets_list]
    current_user.updated(@page)
    render plain: I18n.t(:order_changed)
  rescue => exc
    render plain: I18n.t(:error_saving_new_order_message, error_message: exc.message)
  end

  protected

  # just carrying over stuff from the old gallery controller here
  def setup_view
    @show_right_column = true
    if action?(:show)
      @discussion = false # disable load_posts()
      @show_posts = true
    end
  end

  # do not display comments
  def setup_options
    @options.show_posts = false
  end
end
