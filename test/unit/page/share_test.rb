require 'test_helper'

class Page::SharingTest < ActiveSupport::TestCase

  fixtures :pages, :users, :groups, :memberships, :user_participations

  def test_share_hash
    user = users(:kangaroo)
    group = groups(:animals)
    user2 = users(:red)

    page = Page.create(title: 'x', user: user, access: :admin)
    user.share_page_with!(page, {'animals' => {access: "edit"}, 'red' => {access: "edit"}}, {})

    assert group.may?(:edit, page)
    assert !group.may?(:admin, page)
    assert user2.may?(:edit, page)
    assert !user2.may?(:admin, page)
  end

  def test_notify_groups
    creator = users(:kangaroo)
    red = users(:red)
    rainbow = groups(:rainbow)

    page = Page.create!(title: 'title', user: creator, share_with: ['red', 'rainbow', 'animals'], access: :admin)

    creator.share_page_with!(page, ['red', 'rainbow', 'animals'], send_notice: true, send_message: 'hi')
    page.save!
    page.reload

    all_users = (groups(:animals).users + groups(:rainbow).users).uniq.select do |user|
      creator.may?(:pester, user)
    end

    assert_equal all_users.collect{|user|user.name}.sort, page.users.collect{|user|user.name}.sort
  end

  def test_notify_with_hash
    creator = users(:kangaroo)
    red = users(:red)
    rainbow = groups(:rainbow)

    page = Page.create!(title: 'title', user: creator,
     share_with: {"rainbow"=>{"access"=>"admin"}, "red"=>{"access"=>"admin"}},
     access: :view)
    assert rainbow.may?(:admin, page)

    creator.share_page_with!(
      page,
      {"rainbow"=>{"send_notice"=>"1"}, "red"=>{"send_notice"=>"1"}},
      {"send_notice"=>true, "send_message"=>"", "send_email"=>false}
    )
    page.save!
    page.reload

    all_users = (groups(:rainbow).users).uniq.select do |user|
      creator.may?(:pester, user)
    end
    all_users << creator
    assert_equal all_users.collect{|user|user.name}.sort, page.users.collect{|user|user.name}.sort
  end

  protected

  def create_page(options = {})
    defaults = {title: 'untitled page', public: false}
    Page.create(defaults.merge(options))
  end

end
