require 'test_helper'

class Wiki::WikisControllerTest < ActionController::TestCase
  def setup
    @user = users(:blue)
    @group = groups(:rainbow)
    @group2 = groups(:groupwithcouncil) # all members may edit the wiki is false
    @user2 = users(:dolphin)# not a member of rainbow
    @user3 = users(:red) # not in council of groupwithcouncil
  end

  def test_edit
    @wiki = create_profile_wiki
    login_as @user
    xhr :get, :edit, id: @wiki.id
    assert_response :success
    assert_template 'wiki/wikis/edit'
    assert_equal 'text/javascript', @response.content_type
    assert_equal @group, assigns(:group)
    assert_equal @wiki, assigns['wiki']
    assert_equal @group, assigns['context'].entity
    assert_equal @user, @wiki.reload.locker_of(:document)
  end

  def test_edit_without_council_powers_not_allowed
    @wiki = @group2.profiles.private.create_wiki body: 'private'
    login_as @user3
    assert_permission_denied do
      xhr :get, :edit, id: @wiki.id
    end
  end

  def test_edit_as_non_member_not_allowed
    @wiki = create_profile_wiki
    login_as @user2
    assert_permission_denied do
      xhr :get, :edit, id: @wiki.id
    end
  end

  def test_edit_locked
    @wiki = create_profile_wiki
    other_user = FactoryBot.create(:user)
    @wiki.lock! :document, other_user
    login_as @user
    xhr :get, :edit, id: @wiki.id
    assert_response :success
    assert_template 'common/wikis/_locked'
    assert_equal 'text/javascript', @response.content_type
    assert_equal other_user, @wiki.locker_of(:document)
    assert_equal @wiki, assigns['wiki']
  end

  def test_update_group_wiki
    @wiki = create_profile_wiki
    login_as @user
    xhr :post, :update,
        id: @wiki.id,
        wiki: { body: '*updated*', version: 1 },
        save: true
    assert_equal '<p><strong>updated</strong></p>', @wiki.reload.body_html
  end

  def test_update_page_wiki
    @wiki = create_page_wiki
    login_as @user
    xhr :post, :update,
        id: @wiki.id,
        wiki: { body: '*updated*', version: 1 },
        save: true
    assert_equal '<p><strong>updated</strong></p>', @wiki.reload.body_html
    assert_equal @user.login, @wiki.page.updated_by_login
  end

  def test_cancel_update
    @wiki = create_page_wiki
    login_as @user
    former = @wiki.body_html
    xhr :post, :update,
        id: @wiki.id,
        wiki: { body: '*updated*', version: 1 },
        cancel: true
    assert_equal former, @wiki.reload.body_html
    assert @user.login != @wiki.page.updated_by_login,
           'cancel should not set updated_by'
  end

  def test_show_wiki_on_public_page
    @wiki = create_page_wiki
    @page.public = true
    @page.save
    xhr :get, :show, id: @wiki.id
    assert_response :success
    assert_equal @wiki, assigns['wiki']
  end

  def test_hide_wiki_on_private_page
    @wiki = create_page_wiki
    assert_permission_denied do
      xhr :get, :show, id: @wiki.id
    end
  end

  def test_show_private_group_wiki
    @wiki = create_profile_wiki(true)
    login_as @user
    xhr :get, :show, id: @wiki.id
    assert_response :success
    assert_equal @wiki, assigns['wiki']
  end

  def test_show_public_group_wiki_to_stranger
    @wiki = create_profile_wiki
    @group.grant_access! public: :view
    xhr :get, :show, id: @wiki.id
    assert_response :success
    assert_equal @wiki, assigns['wiki']
  end

  def test_do_not_show_private_group_wiki_to_stranger
    @wiki = create_profile_wiki(true)
    assert_permission_denied do
      xhr :get, :show, id: @wiki.id
    end
  end

  ##
  ## SECTION TESTS
  ##

  def test_edit_section
    @wiki = create_profile_wiki
    login_as @user
    xhr :get, :edit, id: @wiki.id, section: 'section-one'
    assert_response :success
    assert_template 'wikis/_edit'
    assert_equal 'text/javascript', @response.content_type
    markup = <<-EOM.strip_heredoc
      h2. section one

      one

      h3. section one A

      one A

    EOM
    assert_equal markup, assigns['body']
    assert_equal 'section-one', assigns['section']
    assert_equal @wiki, assigns['wiki']
    assert_equal @group, assigns['context'].entity
    assert_equal @user, @wiki.reload.locker_of('section-one')
  end

  def test_edit_locked_section
    @wiki = create_profile_wiki
    other_user = FactoryBot.create(:user)
    @wiki.lock! :document, other_user
    login_as @user
    xhr :get, :edit, id: @wiki.id, section: 'section-one'
    assert_response :success
    assert_template 'wikis/_locked'
    assert_equal 'text/javascript', @response.content_type
    assert_equal other_user, @wiki.locker_of(:document)
    assert_equal @wiki, assigns['wiki']
  end

  def test_update_section
    @wiki = create_profile_wiki
    login_as @user
    xhr :post, :update,
        id: @wiki.id, section: 'section-one',
        wiki: { body: '*updated*', version: 1 },
        save: true
    # this is an xhr so we just render the wiki in place
    assert_response :success
    changed_body = <<-EOB.strip_heredoc
      *updated*

      h2. section two

      two

      h1. big section

      biggie
    EOB
    assert_equal changed_body, @wiki.reload.body
  end

  def create_page_wiki
    owner = FactoryBot.create :user
    @page = FactoryBot.build :wiki_page, owner: owner
    @page.data = Wiki.new(user: owner, body: '')
    @page.save
    @page.wiki.save
    @page.add(@user, access: :edit).save!
    @page.wiki
  end

  def create_profile_wiki(private = false)
    if private
      @group.profiles.private.create_wiki body: 'private'
    else
      @group.profiles.public.create_wiki body: <<-EOB.strip_heredoc
        h2. section one

        one

        h3. section one A

        one A

        h2. section two

        two

        h1. big section

        biggie
      EOB
    end
  end
end
