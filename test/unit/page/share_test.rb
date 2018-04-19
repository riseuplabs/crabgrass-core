require 'test_helper'

class Page::ShareTest < ActiveSupport::TestCase
  def test_share_hash
    user = users(:kangaroo)
    group = groups(:animals)
    user2 = users(:red)
    page = Page.create(title: 'x', user: user, access: :admin)

    share = Page::Share.new page, user
    share.with 'animals' => { access: 'edit' }, 'red' => { access: 'edit' }

    assert group.may?(:edit, page)
    assert !group.may?(:admin, page)
    assert user2.may?(:edit, page)
    assert !user2.may?(:admin, page)
  end

  def test_notify_user_by_email
    user = users(:kangaroo)
    user2 = users(:red)
    Mailer.deliveries = nil
    page = Page.create(title: 'x', user: user, access: :admin)

    share = Page::Share.new page, user,
                            'send_notice' => true,
                            'send_message' => 'hello red',
                            'send_email' => true,
                            'mailer_options' =>  { site: Site.new,
                                                   page: page,
                                                   current_user: user }
    share.with 'red' => { access: 'edit' }
    assert user2.may?(:edit, page)
    assert !user2.may?(:admin, page)
    mail = Mailer.deliveries.first
    assert_includes mail.body, 'hello red'
  end

  def test_notify_groups
    creator = users(:kangaroo)
    red = users(:red)
    rainbow = groups(:rainbow)
    page = Page.create!(title: 'title', user: creator, share_with: %w[red rainbow animals], access: :admin)

    share = Page::Share.new page, creator,
                            send_notice: true,
                            send_message: 'hi'
    share.with %w[red rainbow animals]
    page.save!
    page.reload

    all_users = (groups(:animals).users + groups(:rainbow).users).uniq.select do |user|
      creator.may?(:pester, user)
    end

    assert_equal all_users.collect(&:name).sort, page.users.collect(&:name).sort
  end

  def test_notify_with_hash
    creator = users(:kangaroo)
    red = users(:red)
    rainbow = groups(:rainbow)
    page = Page.create!(title: 'title', user: creator,
                        share_with: { 'rainbow' => { 'access' => 'admin' }, 'red' => { 'access' => 'admin' } },
                        access: :view)
    assert rainbow.may?(:admin, page)

    share = Page::Share.new page, creator,
                            'send_notice' => true,
                            'send_message' => '',
                            'send_email' => false
    share.with 'rainbow' => '1', 'red' => '1', ':contributors' => '0'

    page.save!
    page.reload

    all_users = groups(:rainbow).users.uniq.select do |user|
      creator.may?(:pester, user)
    end
    all_users << creator
    assert_equal all_users.collect(&:name).sort, page.users.collect(&:name).sort
  end

  # send notification to special symbols :participants or :contributors
  def test_notify_special
    owner = users(:kangaroo)
    userlist = [users(:dolphin), users(:penguin), users(:iguana)]
    page = Page.create!(title: 'title', user: owner, share_with: userlist, access: :edit)
    share = Page::Share.new(page, owner, send_notice: true)

    # send notice to participants
    assert_difference('Notice::PageNotice.count', 4) do
      share.with ':participants'
    end

    # send notice to contributors
    page.add(users(:penguin), changed_at: Time.now) # simulate contribution
    page.add(users(:kangaroo), changed_at: Time.now)
    page.save!
    assert_not_nil page.user_participations.find_by_user_id(users(:kangaroo).id).changed_at
    assert_difference('Notice::PageNotice.count', 2) do
      share.with ':contributors'
    end
  end

  protected

  def create_page(options = {})
    defaults = { title: 'untitled page', public: false }
    Page.create(defaults.merge(options))
  end
end
