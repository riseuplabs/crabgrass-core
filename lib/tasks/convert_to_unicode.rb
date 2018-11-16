#
# Even though database.yml sais utf8, the existing tables in production
# still need to be migrated.
#
# This forced convert to unicode seems to be required to get certain
# languages to work # (like multi-byte languages).
# The mb4 extension is required to get 4 byte utf8 chars to work -
# in particular utf8 emoticons.
#
# This task should only need to be run once.
# However, running it again will be slow as it rebuilds all indexes but won't hurt.
#
#

namespace :cg do
  desc 'converts mysql tables to use unicode. specifying utf8mb4 in database.yml is not enough.'
  task(convert_to_unicode: :environment) do
    charset = 'utf8mb4'
    collation = 'utf8mb4_unicode_ci'
    @connection = ActiveRecord::Base.connection
    @connection.execute "ALTER DATABASE `#{@connection.current_database}` CHARACTER SET #{charset} COLLATE #{collation}"
    @connection.tables.each do |table|
    next if table == 'schema_migrations'
      if table == 'tags' # tags need a binary collation
        @connection.execute "ALTER TABLE `#{table}` CONVERT TO CHARACTER SET #{charset} COLLATE utf8mb4_bin"
      else
        @connection.execute "ALTER TABLE `#{table}` CONVERT TO CHARACTER SET #{charset} COLLATE #{collation}"
      end
    end
  end
end
