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
    when 'notices_send'
      PageHistory.send_single_pending_notifications
    when 'notices_send_digests'
      PageHistory.send_digest_pending_notifications
    when 'tracking_update_hourlies'
      Tracking::Page.process
    when 'tracking_update_dailies'
      Tracking::Daily.update
    when 'cache_session_clean'
      clean_session_cache
    when 'cache_fragment_clean'
      clean_fragment_cache
    when 'codes_expire'
      Code.cleanup_expired
    else
      raise 'no such cron action'
    end
    render text: '', layout: false
  end

  protected

  #
  # for now, we only allow cron controller to be trigger from localhost.
  # this seems reasonable.
  #
  def allow_only_requests_from_localhost
    unless request.remote_addr == '127.0.0.1'
      render text: 'not allowed'
    end
  end

  #
  # remove all files that have had their status changed more than three days ago.
  # (on a system with user accounts, tmpreaper should be used instead.)
  #
  def clean_fragment_cache
    find_old_and_remove Rails.root+'/tmp/sessions'
  end

  #
  # remove all files that have had their status changed more than three days ago.
  # (on a system with user accounts, tmpreaper should be used instead.)
  #
  def clean_session_cache
    find_old_and_remove Rails.root+'/tmp/sessions'
  end

  def find_old_and_remove(path)
    system("find", path.to_s, '-ctime', '+3', '-exec', 'rm', '{}', ';')
  end

end
