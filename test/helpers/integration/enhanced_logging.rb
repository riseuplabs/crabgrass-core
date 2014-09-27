module EnhancedLogging
  require 'pp'

  def teardown
    super
    unless passed?
      save_state
    end
  rescue # in case some teardown hook crashed
    save_state
    raise
  end

  def save_state
    begin
      page.save_screenshot screenshot_path
    rescue Capybara::NotSupportedByDriverError
    end
    File.open(logfile_path, 'w') do |test_log|
      test_log.puts self.class.name
      test_log.puts "========================="
      test_log.puts __name__
      test_log.puts Time.now
      if page.current_path
        test_log.puts page.current_path
        test_log.puts page.status_code
        test_log.puts page.response_headers
        test_log.puts "page.html"
        test_log.puts "------------------------"
        test_log.puts page.html
      end
      if page.driver.respond_to? :network_traffic
        test_log.puts "network traffic"
        test_log.puts "------------------------"
        PP.pp page.driver.network_traffic, test_log
      end
      test_log.puts "server log"
      test_log.puts "------------------------"
      test_log.puts `tail log/test.log -n 1000`
    end
  end

  protected


  def logfile_path
    Rails.root + 'tmp' + "#{self.class.name.underscore}.#{__name__}.log"
  end

  def screenshot_path
    Rails.root + 'tmp' + "#{self.class.name.underscore}.#{__name__}.png"
  end

end
