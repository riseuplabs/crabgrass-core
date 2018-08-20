require 'bundler/gem_tasks'

require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << 'test/lib'
  t.test_files = Dir.glob('test/*_test.rb') + Dir.glob('test/{controller,template}/**/*_test.rb')
  t.warning = true
  t.verbose = true
end
