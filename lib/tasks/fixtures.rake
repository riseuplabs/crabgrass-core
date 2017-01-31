
namespace :db do
  namespace :fixtures do
    desc 'Create YAML test fixtures from a particular table in an existing database. Requires TABLE env set.'
    task :dump => :environment do
      table = ENV['TABLE']
      unless ActiveRecord::Base.connection.tables.include?(table)
        puts 'Table "%s" not found' % table
        exit
      end
      ActiveRecord::Base.establish_connection
      i = "000"
      sql  = "SELECT * FROM `#{table}`"
      filename = Rails.root + "test/fixtures/#{table}.yml"
      File.open(filename, 'w') do |file|
        data = ActiveRecord::Base.connection.select_all(sql)
        file.write data.inject({}) {|hash, record|
          hash["#{table}_#{i.succ!}"] = record
          hash
        }.to_yaml
      end
    end

    # Overwrite the default rails task to include our custom classes
    # (see https://github.com/rails/rails/issues/9516#issuecomment-54727124)
    # UPGRADE: this rake task should be replaced with the new version
    # and the hash in the last call should be added.
    # RAILS5 will fix this.
    Rake::Task["db:fixtures:load"].clear
    desc "Load fixtures into the current environment's database. Load specific fixtures using FIXTURES=x,y. Load from subdirectory in test/fixtures using FIXTURES_DIR=z. Specify an alternative path (eg. spec/fixtures) using FIXTURES_PATH=spec/fixtures."
    task :load => [:environment, :load_config] do
      require 'active_record/fixtures'

      base_dir = if ENV['FIXTURES_PATH']
        STDERR.puts "Using FIXTURES_PATH env variable is deprecated, please use " +
                    "ActiveRecord::Tasks::DatabaseTasks.fixtures_path = '/path/to/fixtures' " +
                    "instead."
        File.join [Rails.root, ENV['FIXTURES_PATH'] || %w{test fixtures}].flatten
      else
        ActiveRecord::Tasks::DatabaseTasks.fixtures_path
      end

      fixtures_dir = File.join [base_dir, ENV['FIXTURES_DIR']].compact

      (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir["#{fixtures_dir}/**/*.yml"].map {|f| f[(fixtures_dir.size + 1)..-5] }).each do |fixture_file|
        ActiveRecord::FixtureSet.create_fixtures fixtures_dir, fixture_file,
          castle_gates_keys: CastleGates::Key,
          federatings: Group::Federating,
          memberships: Group::Membership,
          relationships: User::Relationship,
          taggings: ActsAsTaggableOn::Tagging,
          tags: ActsAsTaggableOn::Tag,
          tokens: User::Token,
          "page/terms" => Page::Terms
      end
    end
  end
end
