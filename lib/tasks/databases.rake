namespace :db do
  desc "establishes a database connection for other tasks to use. this can replace loading the whole environment in some cases"
  task :establish_connection  do
    require 'active_record' unless defined? ActiveRecord
    require 'erb' unless defined? ERB
    tasks_dir = File.dirname(__FILE__)
    db_conf = File.join(tasks_dir, '..', '..', 'config', 'database.yml')
    configurations = YAML::load(ERB.new(IO.read(db_conf)).result)
    ActiveRecord::Base.configurations = configurations
    ActiveRecord::Base.establish_connection
  end

  Rake::Task["db:abort_if_pending_migrations"].clear_prerequisites
  task :abort_if_pending_migrations => :establish_connection
end



