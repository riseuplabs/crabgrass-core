namespace :cron do

  def run(desc)
    begin
      yield
    rescue
      # print the error somewhere, something like "Task '#{desc}' failed: "+$!
    end
  end

  desc "hourly tasks"
  task :hourly_tasks do
    run("Tracking") { Tracking.process }
  end

  desc "run daily tasks"
  task :daily_tasks do
    run("Daily update") { Daily.update }
    run("Cleanup expired code") { Code.cleanup_expired }
  end
end
