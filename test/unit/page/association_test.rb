require 'test_helper'

class Page::AssociationTest < ActiveSupport::TestCase

  def test_autosave_user_participations
    owner = users(:kangaroo)
    userlist = [users(:penguin), users(:iguana)]
    page = Page.create!(title: 'title', user: owner, share_with: userlist, access: :edit)

    # simulate contributions
    page.add(users(:penguin), changed_at: Time.now)
    page.add(users(:kangaroo), changed_at: Time.now)
    page.save!

    assert page.contributor?(users(:penguin))
    refute page.contributor?(users(:iguana))
  end

  def test_autosave_group_participations
    owner = users(:kangaroo)
    group = groups(:animals)
    page = Page.create!(title: 'title', user: owner, share_with: group, access: :read)

    page.add(group, access: :admin)
    # not updated yet...
    refute group.may?(:edit, Page.find(page.id))
    page.save!
    assert group.may?(:edit, Page.find(page.id))
  end
end
