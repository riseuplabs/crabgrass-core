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

set :host, ENV['RAILS_ENV'] === 'development' ?
  'localhost:3000' :
  (ENV['RAILS_HOST'] || 'localhost')

job_type :curl, 'curl -L -XPOST http://:host/do/cron/run/:task'

every 1.hour, at: '0:30' do
  curl 'tracking_update_hourlies'
end

# reindex currently takes R = 80sec.
# delta index takes d = 5ms longer for each document in the delta.
# Minimum total time is for delta growing up to
#    sqr( 2*R / d) ~ 180 documents
every 6.hour, at: '0:40' do
  rake 'ts:index'
end

every 1.day do
  curl 'codes_expire'
  curl 'tracking_update_dailies'
end
