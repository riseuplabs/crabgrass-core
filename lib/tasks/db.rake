namespace :db do
  namespace :data do
    desc 'Validates all records in the database'
    task :validate => :environment do
      original_log_level = ActiveRecord::Base.logger.level
      ActiveRecord::Base.logger.level = 1
      puts 'Validate database (this will take some time)...'
      Dir["#{Rails.root}/app/models/**/*.rb"].each { |f| require "#{ f }" }
      ActiveRecord::Base.subclasses.
#        reject { |type| type.to_s.include? '::' }. # subclassed classes are not our own models
        each do |type|
          puts "Validating #{type.count} records for #{type}"
          begin
            type.find_each do |record|
              $stderr.print '.' if (record.id % 200 == 0 )
              $stderr.puts record.id if (record.id % 10000 == 0 )
              unless record.valid?
                puts "#<#{ type } id: #{ record.id }, errors: #{ record.errors.full_messages }>"
              end
            end
          rescue Exception => e
            puts "An exception occurred: #{ e.message }"
          end
        end

      ActiveRecord::Base.logger.level = original_log_level
    end
  end
end
