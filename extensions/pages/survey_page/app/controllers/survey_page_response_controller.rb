##
## Handles the CRUD for survey responses
##

class SurveyPageResponseController < Page::BaseController
  helper 'survey_page'

  def show
    if @response.user == current_user
      skip_authorization
    else
      authorize @page, permission_level
    end
    redirect_to response_path(get_jump_id, page_id: @page.id) if params[:jump]
  end

  def index
    authorize @page, permission_level
    @responses = @survey.responses.paginate(page: params[:page])
  end

  protected

  def permission_level
    return :show? if @survey.view_may_see_responses?
    return :update? if @survey.edit_may_see_responses?
    return :admin?
  end

  # called early in filter chain
  def fetch_data
    return true unless @page
    @survey = @page.data || Survey.new
    @response = @survey.responses.find_by_id(params[:id]) if params[:id]
  end

  def setup_view
    @show_right_column = true unless action?(:rate)
    @show_posts = action?(:list)
  end

  def next_four_responses(survey)
    responses = survey.responses.unrated_by(current_user, 4)
    if responses.size < 4
      responses += survey.responses.rated_by(current_user, 4 - responses.size)
    end
    responses
  end

  # gets the next or previous response id in the list.
  def get_jump_id
    index = @survey.response_ids.find_index(params[:id].to_i)
    if params[:jump] == 'next'
      return @survey.response_ids[(index + 1) % @survey.response_ids.size]
    elsif params[:jump] == 'prev'
      return @survey.response_ids[index - 1]
    end
  end

  def setup_options
    @options.show_tabs = true
  end
end
