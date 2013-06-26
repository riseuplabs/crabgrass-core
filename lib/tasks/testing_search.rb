require 'yaml'

#
# For thinking_sphinx / sphinxsearch to index pages in crabgrass, we need to have
# a page_terms table with an entry for each page.  This rake task makes sure that
# each page has an up-to-date page_terms entry.
#
# The page_terms.yml file needs to be rebuild any time there is a change to tags,
# taggings, pages, user_participations, or group_participations
#

namespace :cg do
  namespace :test do
    desc "refreshes the auto-generated fixtures"
    task :update_fixtures => :environment do
      #
      # load existing fixtures
      #
      Rake::Task["db:fixtures:load"].invoke
      PageTerms.delete_all

      #
      # regenerate page terms in the database
      #
      val = ThinkingSphinx.deltas_enabled?
      ThinkingSphinx.deltas_enabled = false
      Page.all.each { |page| print "#{page.id} "; page.update_page_terms; STDOUT.flush; }
      ThinkingSphinx.deltas_enabled = val

      #
      # save page_terms to fixture yaml file
      #
      sql  = "SELECT * FROM %s"
      tables = ["page_terms"]
      ActiveRecord::Base.establish_connection
      tables.each do |table_name|
        i = "000"
        File.open(Rails.root + "test/fixtures/#{table_name}.yml", 'w') do |file|
          data = ActiveRecord::Base.connection.select_all(sql % table_name)
          file.write data.inject({}) { |hash, record|
            hash["#{table_name}_#{i.succ!}"] = record
            hash
          }.to_yaml
        end
      end

      #
      # ensure the test db is updated too
      #
      #Rake::Taks["db:test:prepare"].invoke
    end
  end
end

# A task for mysql tuning that cannot be done in schema.rb.
# This should also be set in environment.rb:
#
#     config.active_record.schema_format = :sql
#
# That way, the changes we make here are not lost in schema.rb,
# instead they are captured in development_structure.sql.

#desc "optimize mysql tables for crabgrass."
#task(:optimize => :environment) do
#  connection = ActiveRecord::Base.connection
#  connection.execute 'ALTER TABLE page_terms ENGINE = MyISAM'
#  connection.execute 'CREATE FULLTEXT INDEX idx_fulltext ON page_terms(access_ids, tags)'
#end
