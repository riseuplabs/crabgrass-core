#
# Include Page tests in default test task
#
namespace :test do
  desc 'Test everything: crabgrass, pages and mods.'
  Rake::TestTask.new(:everything) do |t|
    t.libs << 'test'
    t.test_files = FileList['test/**/*_test.rb'] +
      FileList['extensions/pages/**/test/**/*_test.rb']
    t.verbose = true
  end
end

#
# Testing pages
#
namespace :test do
  namespace :pages do
    desc 'Run the plugin tests in extensions/pages/**/test (or specify with PAGE=name)'
    task all: %i[units functionals integration]

    desc 'Run all pages unit tests'
    Rake::TestTask.new(units: :setup_plugin_fixtures) do |t|
      t.libs << 'test'
      t.pattern = "extensions/pages/#{ENV['PAGE'] || '**'}/test/unit/**/*_test.rb"
      t.verbose = true
    end

    desc 'Run all pages functional tests'
    Rake::TestTask.new(functionals: :setup_plugin_fixtures) do |t|
      t.libs << 'test'
      t.pattern = "extensions/pages/#{ENV['PAGE'] || '**'}/test/functional/**/*_test.rb"
      t.verbose = true
    end

    desc 'Integration test engines for pages'
    Rake::TestTask.new(integration: :setup_plugin_fixtures) do |t|
      t.libs << 'test'
      t.pattern = "extensions/pages/#{ENV['PAGE'] || '**'}/test/integration/**/*_test.rb"
      t.verbose = true
    end

    desc 'Mirrors plugin fixtures into a single location to help plugin tests'
    task setup_plugin_fixtures: :environment do
      # Engines::Testing.setup_plugin_fixtures
    end
  end
end
