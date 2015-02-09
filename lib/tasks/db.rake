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
          total = type.count
          puts "\rValidating #{total} records for #{type}"
          begin
            # UPGRADE:
            # rails 4 has find_each.with_index
            index = 0
            type.find_each do |record|
              index += 1
              $stderr.print "\r #{index}/#{total}" if (index % 100 == 0 )
              unless record.valid?
                print "\r#<#{ type } id: #{ record.id }, errors: #{ record.errors.full_messages }>\n"
              end
            end
          rescue Exception => e
            print "\rAn exception occurred: #{ e.message }\n"
          end
        end

      ActiveRecord::Base.logger.level = original_log_level
    end
  end
end
