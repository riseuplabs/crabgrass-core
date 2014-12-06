# Be sure to restart your server when you modify this file.

# You can add backtrace silencers for libraries that you're using but don't wish to see in your backtraces.
# Rails.backtrace_cleaner.add_silencer { |line| line =~ /my_noisy_library/ }

# We want to keep lines from extensions. So first of all we have to remove the default silencers.
Rails.backtrace_cleaner.remove_silencers!

# now we introduce our own
Rails.backtrace_cleaner.add_silencer { |line|
  (line !~ Rails::BacktraceCleaner::APP_DIRS_PATTERN) &&   # rails defaults
  (line !~ /^\/?(extensions|vendor\/crabgrass_plugins)/ )  # cg stuff in other places
}
