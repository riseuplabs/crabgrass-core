require 'integration_test'

class GroupExpellTest < IntegrationTest

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


  def test_do_not_list_group_pages_after_expel
    # ensure everyone is a longterm member
    Time.stub(:now, 2.weeks.from_now) do
      @user = users(:blue)
      page = create_page(owner: groups(:animals), title: 'animals secrets')
      page.add(users(:kangaroo), star: true, access: :admin)
      page.save!
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
      @user = users(:kangaroo)
      login
      visit '/animals'
      assert_no_content 'animals secrets'
    end
  end

  def test_do_not_list_committee_pages_after_expel
    page = create_page(owner: groups(:cold), title: 'cold colors secrets')
    page.add(users(:penguin), star: true, access: :admin)
    page.save!
    @user = users(:penguin)
    login
    visit '/me'
    assert_content 'cold colors secrets'
    groups(:cold).remove_user! users(:penguin)
    visit '/me'
    assert_no_content 'cold colors secrets'
  end

  protected

  def create_page(options = {})
    defaults = { title: 'untitled page', public: false }
    Page.create(defaults.merge(options))
  end
end
