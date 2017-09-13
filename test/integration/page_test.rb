# encoding: utf-8

require 'integration_test'

class PageTest < IntegrationTest
  PAGE_TYPES = %i[wiki_page gallery discussion_page rate_many_page task_list_page ranked_vote_page asset_page].freeze

  def test_create_all_page_types
    login
    PAGE_TYPES.each do |type|
      create_page type
      assert_page_header
      assert_html_title_with @page.title
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
        assert_not_found
      end
    end
  end

  def test_page_with_umlaut_title
    login
    create_page title: 'Ümläute in the títlè'
    page_title = current_url.to_s.split('/').last.split('+').first
    assert_equal URI.encode('Ümläute-in-the-títlè'), page_title
  end
end
