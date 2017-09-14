require 'crabgrass/page/engine'

module CrabgrassSurveyPage
  class Engine < ::Rails::Engine
    include Crabgrass::Page::Engine

    register_page_type :SurveyPage,
                       controller: %w[survey_page survey_page_response],
                       icon: 'page_survey',
                       class_group: 'vote',
                       order: 4,
                       forbid_new: true # so we cannot add new ones, but can search for existing ones

    # config.to_prepare do
    #   User.send :include, SurveyUserExtension
    # end
  end
end
