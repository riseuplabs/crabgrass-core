module FixtureTestHelper
  # we use transactional fixtures for everything except page terms
  # page_terms is a different table type (MyISAM) which doesn't support
  # transactions this method will reload the original page terms from
  # the fixture files
  def reset_page_terms_from_fixtures
    fixture_path = ActiveSupport::TestCase.fixture_path
    ActiveRecord::FixtureSet.reset_cache
    ActiveRecord::FixtureSet.create_fixtures fixture_path,
      ['page/terms'],
      'page/terms' => Page::Terms
  end
end
