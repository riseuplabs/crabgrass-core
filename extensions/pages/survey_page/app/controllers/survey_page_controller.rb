
class SurveyPageController < Page::BaseController
  helper 'survey_page'

  def show
    authorize @page
    if @page.data.nil?
      redirect_to page_url(@page, action: 'edit')
    else
      @survey.responses(true)
      # ^^ there is no good reason why this is necessary, but it seems to be the case.
    end
  end

  protected

  def fetch_data
    @survey = @page.data || Survey.new
  end

  def setup_view # maybe want to change
    @show_right_column = true
  end

  def setup_options
    @options.show_tabs = true
  end
end
