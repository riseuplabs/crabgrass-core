class AssetsController < ApplicationController
  before_action :symlink_public_asset, only: :show
  after_action :verify_authorized

  prepend_before_action :fetch_asset, only: %i[show destroy]

  def show
    authorize @asset
    file = file_to_send
    send_file private_filename(file),
              type: file.content_type,
              disposition: disposition(file)
  rescue ActionController::MissingFile
    raise_not_found :file
  end

  def destroy
    authorize @asset
    @asset.destroy
    current_user.updated(@page)
    respond_to do |format|
      format.js { render 'common/assets/destroy' }
      format.html do
        success ['attachment deleted']
        redirect_to(page_url(@page))
      end
    end
  end

  protected

  ## Before Filters

  def fetch_asset
    @asset = Asset.find(params[:id]).version_or_self(params[:version])
    raise_not_found :file unless @asset
    @page = @asset.page
    true
  end

  # Update access and redirect to the same path - which will now have a
  # symlink in public
  def symlink_public_asset
    if @asset.symlink_missing?
      @asset.update_access
      # redirect to the same url again, but next time they will get the symlinks
      redirect_to
    end
  rescue Errno::ENOENT
    Rails.logger.error "File for Asset ##{@asset.id} has not been found."
  end

  ## Helper Methods

  def file_to_send
    if thumb_name
      thumb = @asset.thumbnail(thumb_name)
      raise_not_found :file unless thumb
      thumb.generate
      thumb
    else
      @asset
    end
  rescue Errno::ENOENT => e
    Rails.logger.warn "WARNING: Asset not found: #{thumb_name}"
    raise_not_found :file
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
    if params[:path] =~ /#{THUMBNAIL_SEPARATOR}(?<thumb>[a-z]+)$/
      $LAST_MATCH_INFO['thumb'].to_sym
    end
  end

  # returns 'inline' for formats that web browsers can display, 'attachment' otherwise.
  def disposition(asset)
    if ['image/png', 'image/jpeg', 'image/gif'].include? asset.content_type
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
