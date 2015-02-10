namespace :db do
  namespace :data do
    desc 'Validates all records in the database'
    task :validate => :environment do
      invalid = []
      puts 'Validate database (this will take some time)...'

      Dir["#{Rails.root}/app/models/**/*.rb"].each { |f| require "#{ f }" }

      ActiveRecord::Base.subclasses.each do |type|
        total = type.count
        puts "\rValidating #{total} records for #{type}"
        index = 0
        begin
          # UPGRADE:
          # rails 4 has find_each.with_index
          type.find_each do |record|
            index += 1
            invalid << track_invalid(record)
            $stderr.print "\r #{index}/#{total}" if (index % 100 == 0 )
          end
        rescue StandardError => e
          print "\rAn exception occurred: #{ e.message }\n"
          # This error most likely uccured during batch instantiation.
          invalid << {
            class: type,
            index: index,
            error: e.message
          }
        end
      end
      invalid.compact!

      File.open('log/invalid.yml', 'w') {|f| f.write invalid.to_yaml }

    end

    task :revalidate => :environment do
      invalid = YAML.load_file('log/invalid.yml')
      total = invalid.count
      puts "Revalidating #{total} records."
      still_invalid = invalid.each_with_index.map do |track, index|
        $stderr.print "\r #{index}/#{total}" if (index % 100 == 0 )
        if track[:id]
          begin
            record = track[:class].find(track[:id])
          rescue ActiveRecord::RecordNotFound
            # The record is gone. That's fine. It's not invalid anymore.
            next
          end
          track_invalid(record)
        end
        #TODO: handle index by revalidating all records following that index
      end.compact

      File.open('log/invalid.yml', 'w') {|f| f.write still_invalid.to_yaml }
    end

    def track_invalid(record)
      begin
        return if record.valid?
        print_errors(record, record.errors.full_messages)
      rescue StandardError => e
        record.errors.add(:base, e.message)
        print_errors(record, e.message)
      end
      return {
        class: record.class,
        id: record.id,
        error: record.errors.full_messages
      }
    end

    def print_errors(record, errors)
      print "\r#<#{ record.class } id: #{ record.id }, errors: #{ errors }>\n"
    end
  end
end
