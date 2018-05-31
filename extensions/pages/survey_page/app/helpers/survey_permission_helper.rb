module SurveyPermissionHelper
  # This is a remainder of the SurveyPermissions in the old permission
  # system.
  #
  # It is only used to render the survey and the responses.
  # Surveys define their own permission system (ugh...)
  # Therefore this ends up being pretty complex.
  #
  # In order to clean it up we will need to:
  # * investigate which survey permissions are actually used
  # * drop that level of flex if we do not need it.
  # * use pundit based policies instead.

  # you should be able to view responses even if responses are disabled.
  def may_view_survey_response?(response = @response)
    return false unless logged_in?

    if response and response.user_id == current_user.id
      true # you can always see your own
    elsif current_user.may?(:admin, @page)
      true
    elsif current_user.may?(:edit, @page)
      @survey.edit_may_see_responses?
    elsif current_user.may?(:view, @page)
      @survey.view_may_see_responses?
    else
      false
    end
  end

  def may_view_survey_response_ratings?(_response = nil)
    return false unless logged_in?

    if current_user.may?(:admin, @page)
      true
    elsif current_user.may?(:edit, @page)
      @survey.edit_may_see_ratings?
    elsif current_user.may?(:view, @page)
      @survey.view_may_see_ratings?
    else
      false
    end
  end

  # we assume that may_view_survey_response has already been
  # called and returned true.
  def may_view_survey_question?(response, question)
    return false unless logged_in?

    if question.private?
      if current_user.may?(:admin, @page)
        true
      elsif current_user.id == response.user_id
        true
      else
        false
      end
    else
      true
    end
  end
end
