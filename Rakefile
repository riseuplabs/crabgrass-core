# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

class Rake::Task
  def overwrite(&block)
    @actions.clear
    prerequisites.clear
    enhance(&block)
  end
end


Rake::Task["db:abort_if_pending_migrations"].overwrite do
  require 'active_record' unless defined? ActiveRecord
  require 'erb'
  db_conf = File.join(File.dirname(__FILE__), 'config', 'database.yml')
  configurations = YAML::load(ERB.new(IO.read(db_conf)).result)
  ActiveRecord::Base.configurations = configurations
  ActiveRecord::Base.establish_connection
  pending_migrations = ActiveRecord::Migrator.new(:up, 'db/migrate').pending_migrations

  if pending_migrations.any?
    puts "You have #{pending_migrations.size} pending migrations:"
    pending_migrations.each do |pending_migration|
      puts '  %4d %s' % [pending_migration.version, pending_migration.name]
    end
    abort %{Run "rake db:migrate" to update your database then try again.}
  end
end
