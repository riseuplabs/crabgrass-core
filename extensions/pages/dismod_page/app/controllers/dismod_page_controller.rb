class DismodPageController < Pages::BaseController

  def show
  end

  def update
  end

  def destroy
    asset_version = @asset.versions.find_by_version(params[:version])
    asset_version.destroy
    notice 'version %s destroyed' % asset_version.version
  end

  #
  # used for communication with the Model Design Agent
  #
  def dataset
    if request.get?
      # return the dismod input file to the model design agent
      if params[:version]
        asset_version = @asset.versions.find_by_version(params[:version])
        raise_not_found unless asset_version
        send_file(asset_version.private_filename, :type => asset_version.content_type)
      else
        # we should never get here, really. There is no point in fetching
        # a model that has not yet been uploaded.
        render :text => "xxxxx\nyyyyy\nzzzzz"
      end
    elsif request.post?
      # get the dismod input file from the model design agent
      dismod_input = params[:dismod_input]
      if save_asset(dismod_input)
        render :text => "success"
      else
        render :text => "failure", :status => 500
      end
    end
  end

  #
  # run the java web start "DisMod Model Design Agent"
  #
  # This does not work in Chrome:
  # http://code.google.com/p/chromium/issues/detail?id=10877
  # 
  # Chrome users must download the .jnlp file, right click to say
  # "Always open this type of file", and then manually clear the
  # files from Downloads folder.
  #
  def Model_Design_Agent
    if false
      # for debugging, so we can see the jnlp text
      headers["Content-Type"] = "text/xml"
    else
      headers["Content-Type"] = "application/x-java-jnlp-file"
    end
    headers["Cache-Control"] = "public"
    render :layout => false
  end

  protected

  #
  # creates a new asset or pushes a new version onto our existing asset.
  # returns false if there was a failure to save.
  #
  def save_asset(data)
    return false unless data.any?
    if @asset
      @asset.update_attributes(:data => data, :filename => new_filename(@asset.version))
    elsif @page
      @asset = Asset.create! :data => data, :filename => new_filename(0), :content_type => 'application/dismod-input'
      @page.data = @asset
      @page.save!
    end
  end

  def setup_options
    @options.show_assets = false
  end

  def fetch_data
    @asset = @page.data if @page
  end

  # 
  # generates a new filename for an uploaded dismod input file.
  #
  def new_filename(version)
    "%s.v%s.%s.json" % [@page.title.nameize, version+1, Time.now.strftime('%Y-%m-%d')]
  end
end

