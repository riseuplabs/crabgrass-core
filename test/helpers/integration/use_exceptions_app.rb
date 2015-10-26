module UseExceptionsApp

  def setup
    super
    Rails.application.config.consider_all_requests_local = false
  end

  def teardown
    super
    Rails.application.config.consider_all_requests_local = true
  end

end
