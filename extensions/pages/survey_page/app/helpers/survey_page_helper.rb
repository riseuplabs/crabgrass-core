module SurveyPageHelper
  include AssetPageHelper
  def show_answers_for_question(_response, question)
    # filter answers for this response and ignore unchecked checkboxes
    answers = @response.answers.select do |a|
      a.question == question && a.value != SurveyAnswer::CHOICE_FOR_UNCHECKED
    end
    render partial: 'survey_page_response/answer', collection: answers
  end

  def render_asset(asset, name)
    if asset.embedding_partial.any?
      render partial: asset.embedding_partial
    else
      thumbnail = asset.thumbnails(:large)
      if thumbnail.nil?
        link_to(image_tag(asset.big_icon, alt: name), asset.url)
      else
        link_to_asset(asset, :large, class: '')
      end
    end
  end
end
