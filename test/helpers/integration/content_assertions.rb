module ContentAssertions

  def assert_content(content)
    assert content.present?, "Checking for empty content is pointless."
    assert page.has_content?(content), "Could not find '#{content}'"
  end

  def assert_no_content(content)
    assert !page.has_content?(content), "Did not expect to find '#{content}'"
  end

  def assert_landing_page(owner)
    assert_content owner.display_name
  end

  def assert_not_found(thing = nil)
    thing ||= :page.t
    assert_content :thing_not_found.t(thing: thing)
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

  def assert_success(message)
    message ||= "Changes saved"
    within "#alert_messages .ok_16" do
      assert_content message
    end
  end

  def assert_page_tab(active)
    within "#page_tabs li.tab.active" do
      assert_content active
    end
  end

end
