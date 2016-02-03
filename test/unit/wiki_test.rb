require 'test_helper'

class WikiTest < ActiveSupport::TestCase


  def setup
    @user = users(:blue)
    @different_user = users(:red)
  end

  def test_wiki_associations
    assert(check_associations(Wiki))
  end

  def test_group_association
    group = FactoryGirl.create(:group)
    wiki = group.profiles.public.create_wiki body: "bla"
    assert_equal group, wiki.group
  end

  def test_wiki_body_html_is_not_nil
    wiki = Wiki.new
    assert_equal "", wiki.body_html
  end

  def test_body_html_not_nil_despite_raw_structure
    wiki = Wiki.new
    wiki.body_html # generates raw_structure
    wiki.body_html = nil
    assert_equal "", wiki.body_html
  end

end


