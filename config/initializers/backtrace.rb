# Be sure to restart your server when you modify this file.

# You can add backtrace silencers for libraries that you're using but
# don't wish to see in your backtraces.
# Rails.backtrace_cleaner.add_silencer do |line|
#   line =~ /my_noisy_library/
# end

# We want to keep lines from extensions. So first of all we have to
# remove the default silencers.
Rails.backtrace_cleaner.remove_silencers!

# now we introduce our own
Rails.backtrace_cleaner.add_silencer do |line|
  # rails defaults & cg stuff in other places
  (line !~ Rails::BacktraceCleaner::APP_DIRS_PATTERN) &&
    (line !~ /^\/?(extensions|vendor\/crabgrass_plugins)/)
end

# The traces of ActionController::RoutingErrors do not add any info.
# Plus they do not include anything in the clean backtrace.
# - which makes rails resort to the dirty backtrace for some reason.
# So here we strip of the entire backtrace
# to prevent them from cluttering the logs.
class ActionDispatch::DebugExceptions
  alias_method :old_log_error, :log_error
  def log_error(env, wrapper)
    if wrapper.exception.is_a?  ActionController::RoutingError
      stripped = wrapper.exception.class.new wrapper.exception.message
      wrapper = wrapper.class.new env, stripped
    end
    old_log_error env, wrapper
  end
end
