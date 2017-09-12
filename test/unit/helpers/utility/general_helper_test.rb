require 'test_helper'

class Common::Utility::GeneralHelperTest < ActionController::TestCase
  include ::Common::Utility::GeneralHelper

  def test_force_wrap
    title = 'VeryLongTitleWithNoSpaceThatWillBeFarTooLongToFitIntoTheTableColumnAndInTurnBreakTheLayoutUnlessItIsBrokenUsingHiddenHyphens'
    expected = 'VeryLongTitleWithNoS&shy;paceThatWillBeFarToo&shy;LongToFitIntoTheTabl&shy;eColumnAndInTurnBrea&shy;kTheLayoutUnlessItIs&shy;BrokenUsingHiddenHyp&shy;hens'
    assert_equal expected, force_wrap(title)
  end
end
