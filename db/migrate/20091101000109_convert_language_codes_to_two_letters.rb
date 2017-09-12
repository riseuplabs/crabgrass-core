class ConvertLanguageCodesToTwoLetters < ActiveRecord::Migration
  def self.up
    connection = ActiveRecord::Base.connection
    connection.execute(%{ UPDATE languages SET code = LEFT(languages.code, 2) }) if connection.table_exists? 'languages'
    connection.execute(%{ UPDATE users SET language = LEFT(users.language, 2) WHERE language IS NOT NULL })
    connection.execute(%{ UPDATE groups SET language = LEFT(groups.language, 2) WHERE language IS NOT NULL })
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
