# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rdoc/task'

require 'tasks/rails'

begin
  gem 'delayed_job', '~> 2.0'
  require 'delayed/tasks'
rescue LoadError
  STDERR.puts "(delayed_job tasks disabled)"
end

begin
  gem 'thinking-sphinx', '~> 1.4'
  require 'thinking-sphinx'
  require 'thinking_sphinx/tasks'
rescue LoadError
  STDERR.puts "(sphinx tasks disabled)"
end
