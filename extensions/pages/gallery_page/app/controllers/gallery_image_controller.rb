class GalleryImageController < Page::BaseController
  helper 'gallery'

  # show and edit use base page permissions
  guard :may_edit_page?
  guard show: :may_show_page?

  # default_fetch_data is disabled for new in Pages::BaseController
  prepend_before_filter :fetch_page_for_new, only: :new

  def show
    @showing = @page.showings.includes(:asset).find_by_asset_id(params[:id])
    @image = @showing.asset
    # position sometimes starts at 0 and sometimes at 1?
    @image_index = @page.images.index(@image).next
    @image_count = @page.showings.count
    @next = @showing.lower_item
    @previous = @showing.higher_item
  end

  # cleaned out unused edit and update actions here.
  # They were quite powerful. Uploading a number of images at once
  # and supporting zip upload.
  # But now we use the general purpose assets controller instead.
  # That one supports multi file upload and drag&drop.
  #
  # If you want to bring back some of the old features you might be
  # interested in looking at the git history

  # removed an non ajax fallback, azul
  def sort
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
