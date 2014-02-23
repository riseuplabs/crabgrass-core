require_relative '../integration_test'

class PageTest < IntegrationTest

  def test_create_all_page_types
    visit '/'
    login
    [:gallery, :wiki_page, :discussion_page, :rate_many_page, :task_list_page, :ranked_vote_page].each do |type|
      create_page type
      assert_page_header
      cleanup_page
    end
  ensure
    cleanup_user
  end

end
