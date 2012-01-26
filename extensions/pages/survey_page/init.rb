define_page_type :SurveyPage, {
  :controller => 'survey_page',
  :icon => 'page_survey',
  :class_group => 'vote',
  :order => 4,
  :forbid_new => true # so we cannot add new ones, but can search for existing ones
}

#require File.join(File.dirname(__FILE__), 'lib',
#                  'survey_user_extension')
#
#apply_mixin_to_model("User", SurveyUserExtension)

