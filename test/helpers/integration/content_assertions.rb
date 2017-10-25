module ContentAssertions
  def assert_content(content)
    assert content.present?, 'Checking for empty content is pointless.'
    assert page.has_content?(content), "Could not find '#{content}'"
  end

  def assert_no_content(content)
    assert page.has_no_content?(content), "Did not expect to find '#{content}'"
  end

  def assert_landing_page(owner)
    assert_content owner.display_name
    assert_local_tab 'Home'
  end

  def assert_profile_page(owner)
    assert_content owner.display_name
    assert_local_tab 'Profile'
  end

  NOT_FOUND_ERRORS = [
    ActiveRecord::RecordNotFound
  ].freeze
  # We use a Rack middleware to render the 404 page. It can't be tested
  # in RackTest directly. So we just make sure a 404 is returned.
  # The page rendered will be a verbose error page in test env but a
  # simple 'Page not found' error page in production
  def assert_not_found
    assert_equal 404, page.status_code
  end

  def assert_login_failed
    assert_content :login_failed.t
    assert_content :login_failure_reason.t
  end

  def assert_page_header
    within '#title h1' do
      assert_content @page.title
    end
  end

  def assert_html_title_with(start_term)
    assert page.title.lstrip.start_with?(start_term.lstrip),
           "Expected #{page.title} to start with #{start_term}"
  end

  def assert_success(message)
    message ||= 'Changes saved'
    within '#alert_messages .alert-success' do
      assert_content message
    end
  end

  def assert_local_tab(active)
    within '#banner_nav li.tab a.tab.active' do
      assert_content active
    end
  end

  def assert_page_tab(active)
    within '#title_box .nav-tabs li.active' do
      assert_content active
    end
  end
end
