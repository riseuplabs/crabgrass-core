class AssetsController < ApplicationController

  permissions 'assets'
  guard :may_ACTION_asset?

  before_filter :public_or_login_required
  prepend_before_filter :fetch_asset, :only => [:show, :destroy]

  def show
    if @asset.public? and !File.exists?(@asset.public_filename)
      # update access and redirect iff asset is public AND the public
      # file is not yet in place.
      @asset.update_access
      @asset.generate_thumbnails
      if @asset.thumbnails.any?
        redirect_to # redirect to the same url again, but next time they will get the symlinks
      else
        return not_found
      end
    else
      path = params[:path].first
      if thumb_name_from_path(path)
        thumb = @asset.thumbnail( thumb_name_from_path(path) )
        raise_not_found unless thumb
        thumb.generate
        send_file(thumb.private_filename, :type => thumb.content_type, :disposition => disposition(thumb))
      else
        send_file(@asset.private_filename, :type => @asset.content_type, :disposition => disposition(@asset))
      end
    end
  end

  def destroy
    @asset.destroy
    respond_to do |format|
      format.js { render :nothing => true }
      format.html do
        flash_message(:success => "file deleted")
        redirect_to(page_url(@asset.page))
      end
    end
  end

  def create
    @asset = Asset.new params[:asset]
    if params[:asset_title].any?
      @asset.filename = params[:asset_title] + @asset.suffix
    end
    @asset.save!
    redirect_to page_url(@asset.page)
  end

  protected

  def fetch_asset
    if params[:version]
      @asset = Asset.find_by_id(params[:id]).versions.find_by_version(params[:version])
    else
      @asset = Asset.find_by_id(params[:id])
    end
    raise_not_found unless @asset
    true
  end

  #
  # guess if we are viewing a thumbnail or the actual asset
  #
  # TODO: i really don't like how this works. there should be a better way of
  # designating thumbnails, like adding thumb to the prefix path instead of the filename.
  #
  def thumbnail_filename?(filename)
    filename =~ /#{THUMBNAIL_SEPARATOR}/
  end

  def public_or_login_required
    return true unless @asset
    @asset.public? or login_required
  end

  def thumb_name_from_path(path)
    $~[1].to_sym if path =~ /#{THUMBNAIL_SEPARATOR}(.+)\./
  end

  # returns 'inline' for formats that web browsers can display, 'attachment' otherwise.
  def disposition(asset)
    if ['image/png','image/jpeg','image/gif'].include? asset.content_type
      'inline'
    else
      'attachment'
    end
  end

end

