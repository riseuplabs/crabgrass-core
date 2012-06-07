
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
      filename = "#{RAILS_ROOT}/test/fixtures/#{table}.yml"
      File.open(filename, 'w') do |file|
        data = ActiveRecord::Base.connection.select_all(sql)
        file.write data.inject({}) {|hash, record|
          hash["#{table}_#{i.succ!}"] = record
          hash
        }.to_yaml
      end
    end
  end
end