require 'test_helper'

class SurveyTest < ActiveSupport::TestCase
  def setup
    setup_assets
  end

  def teardown
    teardown_assets
  end

  def test_reorder_and_append_complex_survey
    survey = surveys('2')
    # convert survey questions to a hash in a style
    # that we get when a form is submitted
    params_hash = make_params(survey.questions)
    sorted_params = params_hash.collect { |id, attrs| [id, attrs] }
    sorted_params.sort! { |a, b| a.first <=> b.first }

    # delete few things
    params_hash['11'].replace('deleted' => 'true')
    params_hash['12'].replace('deleted' => 'true')
    params_hash['15'].replace('deleted' => 'true')

    # reorder few things
    sorted_params[0], sorted_params[4], sorted_params[6] = sorted_params[4], sorted_params[6], sorted_params[0]

    # add some new ones
    sorted_params << ['new_' + rand.to_s, { 'private' => '0', 'type' => 'ShortTextQuestion', 'position' => 0, 'label' => 'new_q1' }]
    sorted_params.unshift ['new_' + rand.to_s, { 'private' => '0', 'type' => 'ShortTextQuestion', 'position' => 0, 'label' => 'new_q2' }]

    # update positions
    params_hash = {}
    labels = []
    current_position = 1
    sorted_params.each do |id, attrs|
      # deleted stuff should not be given a position
      unless attrs['deleted']
        # store the sorted labels
        labels << attrs['label']
        attrs['position'] = current_position
        current_position += 1
      end

      params_hash[id] = attrs
    end

    skip 'mass assignment protection prevents updating survey this way'
    # We're disabling survey pages for the time being anyway.
    # Also we will use strong_params to fix mass assignments -
    # so no use in fixing the test now.
    survey.new_questions_attributes = params_hash
    survey.save!
    survey.reload
    # check every question
    current_position = 1

    survey.questions.each do |question|
      assert_equal current_position, question.position, 'questions should be sorted'
      assert_equal labels[current_position - 1], question.label
      current_position += 1
    end
  end

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

  def make_params(questions)
    important_attributes = %w[private type label position]
    choices_attribute = 'newline_delimited_choices'
    params = {}
    questions.each do |question|
      question_params = {}
      important_attributes.each { |attr| question_params[attr] = question.attributes[attr] }
      if question.type =~ /Select/
        question_params[choices_attribute] = question.attributes[choices_attribute]
      end
      params[question.id.to_s] = question_params
    end
    params
  end
end
