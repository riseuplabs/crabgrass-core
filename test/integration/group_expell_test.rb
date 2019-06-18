require 'integration_test'

class GroupExpellTest < IntegrationTest

  def teardown
    reset_page_terms_from_fixtures
    super
  end

  def test_expell_other_member
    # ensure everyone is a longterm member
    Time.stub(:now, 2.weeks.from_now) do
      @user = users(:blue)
      login
      visit '/animals'
      click_on 'Members'
      assert first('tr.even').has_content? 'Kangaroo!'
      first('tr.even').click_on 'Remove'
      logout
      @user = users(:penguin)
      login
      visit '/animals'
      click_on 'Members'
      click_on 'Request to Remove Member is pending'
      click_on 'Approve'
      click_on 'Members'
      assert_no_content 'Kangaroo!'
    end
  end

  def test_expell_other_member_second_try
    # ensure everyone is a longterm member
    Time.stub(:now, 2.weeks.from_now) do
      @user = users(:blue)
      login
      visit '/animals'
      click_on 'Members'
      assert first('tr.even').has_content? 'Kangaroo!'
      first('tr.even').click_on 'Remove'
      logout
      @user = users(:penguin)
      login
      visit '/animals'
      click_on 'Members'
      click_on 'Request to Remove Member is pending'
      click_on 'Reject'
      click_on 'Members'
      assert_content 'Kangaroo!'
      logout
      @user = users(:blue)
      login
      visit '/animals'
      click_on 'Members'
      assert first('tr.even').has_content? 'Kangaroo!'
      first('tr.even').click_on 'Remove'
      logout
      @user = users(:iguana)
      login
      visit '/animals'
      click_on 'Members'
      click_on 'Request to Remove Member is pending'
      click_on 'Approve'
      click_on 'Members'
      assert_no_content 'Kangaroo!'
    end
  end


  def test_add_expelled_member
    # ensure everyone is a longterm member
    Time.stub(:now, 2.weeks.from_now) do
      @user = users(:blue)
      login
      visit '/animals'
      click_on 'Members'
      assert first('tr.even').has_content? 'Kangaroo!'
      first('tr.even').click_on 'Remove'
      logout
      @user = users(:penguin)
      login
      visit '/animals'
      click_on 'Members'
      click_on 'Request to Remove Member is pending'
      click_on 'Approve'
      click_on 'Members'
      assert_no_content 'Kangaroo!'
      logout
    end
    Time.stub(:now, 2.months.from_now) do
      groups(:animals).add_user! users(:kangaroo)
      @user = users(:blue)
      login
      visit '/animals'
      click_on 'Members'
      assert first('tr.even').has_content? 'Kangaroo!'
      assert_no_content 'Request to Remove Member is pending'
    end
  end

  def test_leave_network
    # ensure everyone is a longterm member
    Time.stub(:now, 2.weeks.from_now) do
      @user = users(:blue)
      login
      visit '/fai'
      click_on 'Members'
      first('#column_left').click_on 'Groups'
      assert first('tr.even').has_content? 'animals'
      first('tr.even').click_on 'Remove'
      logout
      @user = users(:penguin)
      login
      visit '/fai'
      click_on 'Members'
      first('#column_left').click_on 'Groups'
      click_on 'Request to remove group is pending'
      click_on 'Approve'
      click_on 'Members'
      assert_no_content 'animals'
    end
  end
end
