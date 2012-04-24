require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class WikiPageTest < ActiveSupport::TestCase
  fixtures :users

  # Two WikiPages with the same title added to the same group
  def test_duplicate_title_in_group
    @wiki1 = WikiPage.create :title => 'x61'
    @wiki2 = WikiPage.create :title => 'x61'

    g = Group.create! :name => 'robots'

    @wiki1.add g; @wiki1.save
    @wiki2.add g; @wiki2.save

    assert_equal 'x61', @wiki1.name
    assert @wiki2.name_taken?
    assert !@wiki2.valid?
  end

  # Two WikiPages with the same title created for the same user
  def test_duplicate_title_for_user
    @wiki1 = WikiPage.create :title => 'x61', :owner => 'blue', :user => users(:blue)
    @wiki2 = WikiPage.create :title => 'x61', :owner => 'blue', :user => users(:blue)

    assert_equal 'x61', @wiki1.name,
      'should get the name set to title for the first'

    assert @wiki2.name_taken?,
      "name is taken for the second"

    assert !@wiki2.valid?,
      "wiki with duplicate name is invalid"
  end
end
