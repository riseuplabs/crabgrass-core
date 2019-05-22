require 'test_helper'

class SurveyTest < ActiveSupport::TestCase
  def test_destruction
    survey = Survey.create!
    SurveyQuestion # loads the source file for ImageUploadQuestion
    question = ImageUploadQuestion.create survey: survey

    response_data = {
      'answers_attributes' => {
        question.id.to_s => {
          'question_id' => question.id.to_s, 'value' => upload_data('image.png')
        }
      }
    }
    response = nil
    assert_difference 'Asset.count', 1, 'a new asset should get created' do
      response = survey.responses.create!(response_data)
    end
    assert_difference 'Asset.count', -1, 'an asset should get destroyed' do
      survey.destroy
    end
  end
end
