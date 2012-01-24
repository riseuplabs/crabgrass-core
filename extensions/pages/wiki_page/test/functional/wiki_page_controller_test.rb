require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class WikiPageControllerTest < ActionController::TestCase
  fixtures :pages, :users, :user_participations, :wikis

  def setup
    #HTMLDiff.log_to_stdout = false # set to true for debugging
  end

  def test_show
    login_as :orange

    # existing page
    get :show, :page_id => pages(:wiki).id
    assert_response :success
  end

  def test_failed_show_without_login
    # existing page
    get :show, :page_id => pages(:wiki).id
    assert_response :redirect
    assert_redirected_to :controller => :account, :action => :login
  end

  def test_show_without_login
    get :show, :page_id => pages(:public_wiki).id
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

  # edit, save, done
  # edit, lock stolen, try to save, see lock error, retake lock, save
  # edit, lock stolen, thief saves, try save, see old version error, save (overwrites)
  # test decorate with edit links
  def test_create
    login_as :quentin

    assert_no_difference 'Page.count' do
      post 'create', :id => WikiPage.param_id, :page => {:title => nil}
      assert_equal 'error', flash[:type], "page title should be required"
    end

    assert_difference 'Page.count' do
      post :create, :id => WikiPage.param_id, :group_id=> "", :create => "Create page", :tag_list => "",
           :page => {:title => 'my title', :summary => ''}
      assert_response :redirect
      assert_not_nil assigns(:page)
      assert_not_nil assigns(:page).data

      assert_redirected_to @controller.page_url(assigns(:page), :action => 'show'), "create action should redirect to show"
      get :show, :page_id => assigns(:page).id

      assert_redirected_to @controller.page_url(assigns(:page), :action => 'edit'), "showing empty wiki should redirect to edit"
    end
  end

  def test_print
    login_as :orange

    get :print, :page_id => pages(:wiki).id
    assert_response :success
#    assert_template 'print'
  end

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
