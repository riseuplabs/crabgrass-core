namespace :cron do

  def run(desc)
    begin
      yield
    rescue
      # print the error somewhere, something like "Task '#{desc}' failed: "+$!
    end
  end

  desc "prints suggested crontab"
  task :suggest_crontab do
    cd = 'cd ' + RAILS_ROOT
    find = `which find`.chomp
    crontab = %Q|
# Crabgrass tasks
0 * * * * #{cd}; rake cron:hourly_tasks
0 2 * * * #{cd}; rake cron:daily_tasks
# reindex sphinx
0 * * * * #{cd}; rake ts:index RAILS_ENV=production
# clean up session and cache files
0 3 * * * #{find} #{RAILS_ROOT}/tmp/sessions -ctime +3 -exec rm {} \;
0 3 * * * #{find} #{RAILS_ROOT}/tmp/cache -ctime +3 -exec rm {} \;|
    puts crontab
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
