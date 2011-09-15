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

  # we don't need the whole environment but just a database connection
  # for these tasks:
  [ :abort_if_pending_migrations, "test:purge", "schema:load" ].each do |db_task|
    Rake::Task["db:#{db_task}"].clear_prerequisites
    task db_task => :establish_connection
  end


end



