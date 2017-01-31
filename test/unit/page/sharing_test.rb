require 'test_helper'

class Page::SharingTest < ActiveSupport::TestCase



  def test_better_permission_takes_precedence
    creator = users(:kangaroo)
    red = users(:red)
    rainbow = groups(:rainbow)

    page = Page.create(title: 'a very popular page', user: creator)
    assert page.valid?, 'page should be valid: %s' % page.errors.full_messages.to_s

    assert creator.may?(:admin, page), 'creator should be able to admin page'
    assert_equal false, red.may?(:view, page), 'user red should not see the page'

    # share with user
    page.add(red, access: :view).save!
    red.clear_access_cache
    assert_equal true, red.may?(:view, page), 'user red should see the page'
    assert_equal false, red.may?(:edit, page), 'user red should not be able to edit the page'

    # share with group
    page.add(rainbow, access: :edit).save!
    red.clear_access_cache
    assert_equal true, red.may?(:edit, page), 'user red should be able to edit the page'
    assert_equal true, rainbow.may?(:edit, page), 'group rainbow should be able to edit the page'
  end

  def test_share_page_with_owner
    user = users(:kangaroo)
    group = groups(:animals)
    page = Page.create(title: 'fun fun', user: user, share_with: group, access: :admin)
    assert page.valid?, 'page should be valid: %s' % page.errors.full_messages.to_s
    assert group.may?(:admin, page), 'group be able to admin group'

    page.add(group, grant_access: :view).save
    assert group.may?(:admin, page), 'group should still be able to admin group'
  end

  def test_share_with_view_access
    user = users(:kangaroo)
    other_user = users(:dolphin)
    group = groups(:animals)
    recipients = [group]
    page = Page.create! title: 'an unkindness of ravens',
      user: user,
      share_with: recipients,
      access: :view

    assert group.may?(:view, page), 'group must have view access'
    assert !group.may?(:admin, page), 'group must not have admin access'
  end

  def test_share_rules
    user       = users(:kangaroo)
    other_user = users(:dolphin)
    group      = groups(:animals)
    other_group = groups(:rainbow)
    user_in_other_group = users(:red)
    assert user_in_other_group.member_of?(other_group)
    assert !user_in_other_group.member_of?(group)

    page = Page.create! title: 'an unkindness of ravens',
      user: user,
      share_with: group,
      access: :view

    assert_nil page.user_participations.find_by_user_id(other_user.id), 'just adding access should not create a user participation record for users in the group'

    page.add(other_user, access: :admin).save
    #assert_equal true, page.user_participations.find_by_user_id(other_user.id).inbox?, 'should be in other users inbox'
    assert_equal false, page.user_participations.find_by_user_id(other_user.id).viewed?, 'should be marked unread'
    assert_equal true, other_user.may?(:admin, page), 'should have admin access'

    assert_nil page.user_participations.find_by_user_id(user_in_other_group.id)
    page.add(other_group, access: :view).save
    page.save!
    assert user_in_other_group.may?(:view, page)
    assert_nil page.user_participations.find_by_user_id(user_in_other_group.id)

    share = Page::Share.new(page, user, send_notice: true)
    share.with other_group
    page.save!
    assert_not_nil page.user_participations.find_by_user_id(user_in_other_group.id)
    #assert_equal true, page.user_participations.find_by_user_id(user_in_other_group.id).inbox?
    assert_equal false,
      page.user_participations.find_by_user_id(user_in_other_group.id).viewed?,
      'should be marked unread'
  end

  def test_add_page
    user = FactoryGirl.create(:user)

    page = nil
    assert_nothing_raised do
      page = FactoryGirl.create(:page, title: 'fun fun')
    end

    page.add(user, access: :edit)

    # sadly, page.users is not updated yet.
    assert !page.users.include?(user), 'it would be nice if we could do this'

    assert_nothing_raised do
      page.save!
    end
    assert page.users.include?(user), 'page.users should be updated'

    assert_raises PermissionDenied do
      user.may!(:admin, page)
    end
  end

  def test_page_update
    page = pages(:wiki)
    user = users(:blue)
    page.add(user, access: :admin)
    page.save!

    assert page.user_participations.size > 1
    page.user_participations.each do |up|
      up.update_attribute(:viewed, true)
    end

    user.updated(page)

    page = Page.find(page.id)
    page.user_participations.each do |up|
      assert_equal(false, up.viewed, 'should not be viewed') unless up.user == user
    end
  end

  def test_notify_group_creates_participations
    creator = users(:kangaroo)
    group = groups(:animals)
    page = Page.create!(title: 'title', user: creator, share_with: 'animals', access: 'admin')
    share = Page::Share.new page, creator,
      send_notice: true,
      send_message: "here's a page for you"
    share.with group

    page.save!
    page.reload
    assert_equal groups(:animals).users.count, page.user_participations.count
  end

  def test_only_send_notify_message_to_the_recipient
    creator = users(:blue)
    users = [users(:dolphin), users(:penguin), users(:iguana)]
    additional_user = users(:kangaroo)

    page = Page.create!(title: 'title', user: creator, share_with: users, access: 'admin')
    share = Page::Share.new(page, creator, send_notice: true, send_message: 'hi')

    assert_difference 'Notice::PageNotice.count' do
      share.with additional_user
      page.save!
    end
  end

  def test_cleanup_notify_message_on_page_delete
    creator = users(:blue)
    additional_user = users(:kangaroo)
    page = Page.create!(title: 'title', user: creator, access: 'admin')
    share = Page::Share.new(page, creator, send_notice: true, send_message: 'hi')
    share.with additional_user
    page.save!

    assert_difference 'Notice::PageNotice.count', -1 do
      page.destroy
    end
  end

  # share with a committee you are a member of, but you are not a member of the parent group.
  def test_share_with_committee
    owner = users(:penguin)
    page = Page.create!(title: 'title', user: owner)
    share = Page::Share.new(page, owner)
    committee = groups(:cold)
    assert owner.member_of?(committee)
    share.with committee
    assert page.groups.include? committee
  end

  protected

  def create_page(options = {})
    defaults = {title: 'untitled page', public: false}
    Page.create(defaults.merge(options))
  end

end
