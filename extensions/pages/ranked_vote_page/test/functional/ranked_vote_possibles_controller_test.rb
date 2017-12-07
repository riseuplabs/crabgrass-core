require 'test_helper'

class RankedVotePossiblesControllerTest < ActionController::TestCase
  def setup
    user = users(:orange)
    login_as user
    @page = FactoryBot.create :ranked_vote_page, created_by: user
    @poll = @page.data
  end

  def test_add_possible
    assert_difference '@poll.reload.possibles.count' do
      xhr :post, :create, page_id: @page.id, poll_possible: { name: 'new option', description: '' }
    end
  end
end
