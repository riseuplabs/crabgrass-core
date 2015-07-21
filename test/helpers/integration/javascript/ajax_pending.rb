#
# Ajax Pending
#
# If the server is still budy answering some ajax request while the test ended
# there may be a conflict with both the server and the test threat accessing
# the database. Instead of having this non deteministic behaviour we raise an
# error whenever a test leaves ajax requests unanswered.
#
# In order to make sure all requests have been answered you would usually check
# for the page changes they trigger. Capybara will happily wait for the change.
# If there's no way to check for page changes you can call wait_for_ajax.
#

module AjaxPending

  class Error < StandardError
    def initialize(requests)
      @reqs = requests
    end

    def message
      req = @reqs.last
      "The #{req.method} request to #{req.url} was not answered during the test."
    end
  end

  def teardown
    pending = pending_ajax
    if pending.present?
      # make sure we do not mess up the next test
      wait_for_ajax
      # make this test fail
      raise AjaxPending::Error.new(pending)
    end
  ensure
    super
  end

  #
  # Wait until all ajax requests have received a response.
  # Moves on once there are no requests without a response anymore.
  # This may be too early if you have a response triggering further requests.
  #
  def wait_for_ajax
    page.document.synchronize(Capybara.default_wait_time, errors: [AjaxPending::Error]) do
      pending = pending_ajax
      raise AjaxPending::Error.new(pending) if pending.present?
    end
  end

  def pending_ajax
    # let's not worry about missing images
    pending_requests.reject do |req|
      req.url.include?('.png') or
      req.url.include?('.jpg')
    end
  end

  def pending_requests
    # If the setup of the test failed the driver might not be a js driver
    return [] unless page.driver.respond_to? :network_traffic
    page.driver.network_traffic.select{|req| req.response_parts.blank?}
  end
end
