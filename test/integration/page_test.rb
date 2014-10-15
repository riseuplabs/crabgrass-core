require 'integration_test'

class PageTest < IntegrationTest

  PAGE_TYPES = [:wiki_page, :gallery, :discussion_page, :rate_many_page, :task_list_page, :ranked_vote_page, :asset_page]

  def test_create_all_page_types
    login
    PAGE_TYPES.each do |type|
      create_page type
      assert_page_header
    end
  end

  def test_all_page_types_are_hidden_by_default
    as_a user do
      with_page PAGE_TYPES do |page|
        page.owner = other_user
        page.save
        visit "/#{page.owner_name}/#{page.name_url}"
        assert_equal other_user, page.reload.owner
        assert !page.public?
        assert_content "Permission Denied"
      end
    end
  end

end
