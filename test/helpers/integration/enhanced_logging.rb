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
      page.save_screenshot logpath('png')
    rescue Capybara::NotSupportedByDriverError
    end
    File.open(logpath, 'w') do |test_log|
      test_log.puts self.class.name
      test_log.puts "========================="
      test_log.puts __name__
      test_log.puts Time.now
      if page.current_path
        test_log.puts page.current_path
        test_log.puts page.status_code
        test_log.puts page.response_headers
        File.open(logpath('html'), 'w') do |page_dump|
          page_dump.puts page.html
        end
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
      test_log.puts `tail log/test.log -n 500`
    end
  end

  protected


  def logpath(ext = 'log')
    Rails.root + 'tmp' + "#{self.class.name.underscore}.#{__name__}.#{ext}"
  end

end
