class AssetsController < ApplicationController

  before_filter :authorization_required
  before_filter :symlink_public_asset, only: :show
  permissions 'assets'
  permission_helper 'pages'
  guard :may_ACTION_asset?

  prepend_before_filter :fetch_asset, only: [:show, :destroy]

  def show
    file = file_to_send
    send_file private_filename(file),
      type: file.content_type,
      disposition: disposition(file)
  end

  def destroy
    @asset.destroy
    current_user.updated(@page)
    respond_to do |format|
      format.js {render 'common/assets/destroy' }
      format.html do
        success ['attachment deleted']
        redirect_to(page_url(@page))
      end
    end
  end

  protected

  ## Before Filters

  def fetch_asset
    if params[:version]
      @asset = Asset.find_by_id(params[:id]).versions.find_by_version(params[:version])
    else
      @asset = Asset.find_by_id(params[:id])
    end
    raise_not_found(:file.t) unless @asset
    @page = @asset.page
    true
  end

  # Update access and redirect to the same path - which will now have a
  # symlink in public
  # This only applies iff asset is public AND the public file is not in place.
  def symlink_public_asset
    return unless @asset.public? and !File.exist?(@asset.public_filename)
    @asset.update_access
    @asset.generate_thumbnails
    raise_not_found(:file.t) unless @asset.thumbnails.any?

    # redirect to the same url again, but next time they will get the symlinks
    redirect_to
  end

  ## Helper Methods

  def file_to_send
    if thumb_name
      thumb = @asset.thumbnail(thumb_name)
      raise_not_found unless thumb
      thumb.generate
      thumb
    else
      @asset
    end
  rescue Errno::ENOENT => e
    Rails.logger.warn "WARNING: Asset not found: #{thumb_name}"
    raise_not_found
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

  def thumb_name
    $~['thumb'].to_sym if path =~ /#{THUMBNAIL_SEPARATOR}(?<thumb>[a-z]+)$/
  end

  # read path from params and deal with invalid byte sequence in UTF-8
  # for links created when we still used a different encoding
  def path
    params[:path].try.encode 'UTF-8', 'binary',
      invalid: :replace,
      undef: :replace,
      replace: ''
  end

  # returns 'inline' for formats that web browsers can display, 'attachment' otherwise.
  def disposition(asset)
    if ['image/png','image/jpeg','image/gif'].include? asset.content_type
      'inline'
    else
      'attachment'
    end
  end

  # this exists only to make the test easier. sadly, you can't mock send_file, since then
  # rails looks for a view template.
  def private_filename(asset_or_thumbnail)
    asset_or_thumbnail.private_filename
  end

end

