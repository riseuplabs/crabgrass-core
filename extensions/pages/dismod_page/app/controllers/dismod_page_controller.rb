class DismodPageController < Pages::BaseController

  def show
  end

  def update
  end

  #
  # used for communication with the Model Design Agent
  #
  def dataset
    if request.get?
      # return the dismod input file to the model design agent
      render :text => "xxxxx\nyyyyy\nzzzzz"
    elsif request.post?
      # get the dismod input file from the model design agent
      dismod_input = params[:input_data]
      save_asset(dismod_input)
    end
  end

  #
  # run the java web start "DisMod Model Design Agent"
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

  # creates a new asset or pushes a new version onto our existing asset.
  def save_asset(data)
    if @asset
      @asset.update_attributes(:data => data, :filename => new_filename(asset.version))
    elsif @page
      @page.data = Asset.create! :data => data, :filename => new_filename(1), :content_type => 'application/dismod-input'
      @page.save
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
    "%s.v%s.%s.json" % [@page.title.nameize, version, Time.now.strftime('%Y-%m-%d')]
  end
end

