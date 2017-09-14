require 'test_helper'

class Common::Utility::GeneralHelperTest < ActionController::TestCase
  include ::Common::Utility::GeneralHelper

  def test_force_wrap
    title = 'VeryLongTitleWithNoSpaceThatWillBeFarTooLong' +
      'ToFitIntoTheTableColumnAndInTurnBreakTheLayout' +
      'UnlessItIsBrokenUsingHiddenHyphens'
    expected = 'VeryLongTitleWithNoS&shy;paceThatWillBeFarToo&shy;Long' +
      'ToFitIntoTheTabl&shy;eColumnAndInTurnBrea&shy;kTheLayout' +
      'UnlessItIs&shy;BrokenUsingHiddenHyp&shy;hens'
    assert_equal expected, force_wrap(title)
  end
end
