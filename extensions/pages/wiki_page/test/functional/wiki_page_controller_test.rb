require 'test_helper'

class WikiPageControllerTest < ActionController::TestCase



  def test_show
    login_as :orange
    # existing page
    get :show, id: pages(:wiki)
    assert_response :success
  end

  def test_not_found_without_login
    assert_not_found do
      # existing page
      get :show, id: pages(:wiki)
    end
  end

  def test_show_without_login
    get :show, id: pages(:public_wiki)
    assert_response :success
  end

=begin
This test doesn't work, it was broken before and with the wiki refactoring we
even "lost" the last_seen functionality we might want to implement this later
though.  I think we also need to create a  user_participation for orange with a
last seen date for this to work.

  def test_show_after_changes
    # force a version greater than 1
    page = Page.find(pages(:wiki).id)
    page.data.body = 'new body'
    page.data.save
    page.data.body = 'new new body'
    page.data.save
    page.save

    users(:blue).updated(page)
    login_as :orange
    get :show, :page_id => page.id
    assert_not_nil assigns(:last_seen), 'last_seen should be set, since the page has changed'
  end
=end

  def test_preview
    # TODO:  write action and test
  end

  protected

  def assert_html_for_wiki_section_headings(full_html, html_heading_names)
    # now check that we have all the headings
    html_heading_names.each do |html_heading|

      # Ex: /<h\d+.*?><a name="section-two"><\/a>/
      heading_re = %r{<h\d+.*?><a name="#{html_heading}"></a>}
      assert full_html =~ heading_re, "wiki html should contain [#{html_heading}]"
    end
  end

  def assert_no_html_for_wiki_section_headings(full_html, html_heading_names)
    # now check that we have none of the headings
    html_heading_names.each do |html_heading|

      # Ex: /<h\d+.*?><a name="section-two"><\/a>/
      heading_re = %r{<h\d+.*?><a name="#{html_heading}"></a>}
      assert full_html !~ heading_re, "wiki html should not contain [#{html_heading}]"
    end
  end


end
