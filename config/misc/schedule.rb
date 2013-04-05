#
# This is a configuration file for crabgrass crontab. The gem 'whenever' reads this
# file and uses it to create a crontab.
#
# To see what crontab this would generate:
#
#   whenever -f config/misc/schedule.rb
#
# To install crontab:
#
#   whenever --update-crontab -f config/misc/schedule.rb
#
# For use with capistrano, at top of deploy.rb:
#
#   require 'whenever/capistrano'
#   set :whenever_command, 'whenever -f config/misc/schedule.rb'
#
# See https://github.com/javan/whenever for more details.
#

set :host, ENV['RAILS_ENV'] === 'development' ? 'localhost:3000' : 'localhost'

job_type :curl, 'curl http://:host/do/cron/run/:task'

every 5.minutes do
  curl 'notices_send'
end

every 1.hour, :at => '0:20' do
  curl 'notices_send_digests'
end

every 1.hour, :at => '0:30' do
  curl 'tracking_update_hourlies'
end

every 1.hour, :at => '0:40' do
  curl 'sphinx_reindex'
end

every 1.day do
  curl 'cache_session_clean'
  curl 'codes_expire'
  curl 'tracking_update_dailies'
end

every 3.days do
  curl 'cache_fragment_clean'
end
