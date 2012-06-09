class GalleryImageController < Pages::BaseController

  helper 'gallery'

  # show and edit use base page permissions
  guard :may_edit_page?
  guard :show => :may_show_page?

  # default_fetch_data is disabled for new in Pages::BaseController
  prepend_before_filter :fetch_page_for_new, :only => :new

  def show
    @showing = @page.showings.find_by_asset_id(params[:id], :include => 'asset')
    @image = @showing.asset
    # position sometimes starts at 0 and sometimes at 1?
    @image_index = @page.images.index(@image).next
    @image_count = @page.showings.count
    @next = @showing.lower_item
    @previous = @showing.higher_item
  end

  def edit
    @showing = @page.showings.find_by_asset_id(params[:id], :include => 'asset')
    @image = @showing.asset
    @image_upload_id = (0..29).to_a.map {|x| rand(10)}.to_s
    if request.xhr?
      render :layout => false
    end
  end

  def update
    # whoever may edit the gallery, may edit the assets too.
    raise PermissionDenied unless current_user.may?(:edit, @page)
    @image = @page.images.find(params[:id])
    if params[:assets] #and request.xhr?
      begin
        @image.change_source_file(params[:assets].first)
        # reload might not work if the class changed...
        @image = Asset.find(@image.id)
        responds_to_parent do
          render :update do |page|
            page.replace_html 'show-image', :partial => 'show_image',
              :locals => {:size => 'medium', :no_link => true}
            page.hide('progress')
            page.hide('update_message')
          end
        end
      rescue Exception => exc
        responds_to_parent do
          render :update do |page|
            page.hide('progress')
            page.replace_html 'update_message', $!
          end
        end
      end
    # params[:image] would be something like {:cover => 1} or {:title => 'some title'}
    elsif params[:image] and @image.update_attributes!(params[:image])
      @image.reload
      respond_to do |format|
        format.html { redirect_to page_url(@page,:action=>'show') }
        format.js { render :partial => 'update', :locals => {:params => params[:image]} }
      end
    end
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

end
