#
# This controller is triggered by the crontab, allowing us to run
# scheduled jobs using the existing rails process pool.
#
# This way, we avoid the heavyweight cost of script/runner each time
# cron triggers an action.
#
# The crontab is configured in config/misc/schedule.rb
#

class CronController < ActionController::Base
  before_filter :allow_only_requests_from_localhost

  def run
    case params[:id]
    when 'tracking_update_hourlies'
      Tracking::Page.delay.process
    when 'tracking_update_dailies'
      Tracking::Daily.update
    when 'codes_expire'
      Page::AccessCode.cleanup_expired
    when 'deliver_digests'
      Mailer::PageHistories.deliver_digests
    else
      raise 'no such cron action'
    end
    render nothing: true
  end

  protected

  #
  # for now, we only allow cron controller to be trigger from localhost.
  # this seems reasonable.
  #
  def allow_only_requests_from_localhost
    render plain: 'not allowed' unless request.remote_addr == '127.0.0.1'
  end
end
