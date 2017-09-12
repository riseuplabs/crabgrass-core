require 'test_helper'

class RateManyPossiblesControllerTest < ActionController::TestCase
  # TODO: tests for vote, clear votes, sort

  def setup
    @user = FactoryGirl.create :user
    @page = FactoryGirl.create :rate_many_page, title: 'Show this page!', created_by: @user
  end

  def test_add_possibility
    login_as @user

    assert_difference '@page.data.possibles.count' do
      xhr :post, :create, page_id: @page.id,
                          possible: { name: 'new option', description: '' }
    end
    assert_not_nil assigns(:possible)
  end

  def test_destroy_possibility
    login_as @user
    poll = @page.data
    possible = poll.possibles.create name: 'my option', description: 'undescribable'
    assert_difference 'poll.possibles.count', -1 do
      delete :destroy, page_id: @page.id, id: possible.id
    end
  end

  def test_voting_on_possible
    login_as @user
    poll = @page.data
    possible = poll.possibles.create name: 'my option', description: 'undescribable'

    xhr :post, :update, page_id: @page.id, id: possible.id, value: '2'

    assert_equal 1, poll.votes.by_user(@user).for_possible(possible).count
    assert_equal 2, poll.votes.by_user(@user).for_possible(possible).first.value
  end

  def test_stranger_may_not_vote
    poll = @page.data
    possible = poll.possibles.create name: 'my option', description: 'undescribable'
    stranger = FactoryGirl.create :user

    login_as stranger
    xhr :post, :update, page_id: @page.id, id: possible.id, value: '2'

    assert_equal 0, poll.votes.by_user(stranger).for_possible(possible).count
  end

  def test_participant_may_vote
    poll = @page.data
    possible = poll.possibles.create name: 'my option', description: 'undescribable'
    participant = FactoryGirl.create :user
    @page.add(participant, access: :edit).save
    assert participant.may?(:edit, @page)

    login_as participant
    xhr :post, :update, page_id: @page.id, id: possible.id, value: '2'

    assert_equal 1, poll.votes.by_user(participant).for_possible(possible).count
  end
end
