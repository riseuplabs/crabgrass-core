require 'test_helper'
class CspReportsControllerTest < ActionController::TestCase
  def test_happy_path
    post :create , body: csp_report_json
    assert_response :success
  end

  def csp_report_json
    {"csp-report" => {}}.to_json
  end
end
