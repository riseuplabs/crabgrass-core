##
## TEST DATABASE
##

if (ADAPTER == :sqlite)
  DB_FILE = "#{File.dirname(__FILE__)}/test.sqlite"
  if !File.exist?(DB_FILE)
    REBUILD_DB = true
  end
  ActiveRecord::Base.establish_connection(
    adapter: "sqlite3",
    database: DB_FILE
  )
else
  # if you want to test BIT_OR aggregation function
  ActiveRecord::Base.establish_connection(
    adapter: "mysql",
    host: "localhost",
    database: "castle_gates",
    user: "root"
  )
end

#
# show all db activity
#
if SHOW_SQL
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

def setup_db
  ActiveRecord::Schema.define(version: 1) do

    create_table :castle_gates_keys do |p|
      p.integer :castle_id
      p.string  :castle_type
      p.integer :holder_code
      p.integer :gate_bitfield, default: 1
    end

    create_table :forts do |t|
      t.column :name, :string
      t.column :type, :string
    end
    create_table :towers do |t|
      t.column :name, :string
    end

    create_table :users do |t|
      t.column :name, :string
    end

    create_table :clans do |t|
      t.column :name, :string
    end
    create_table :memberships do |t|
      t.integer :user_id
      t.integer :clan_id
    end

    create_table :minions do |t|
      t.column :name, :string
    end
    create_table :allegiances do |t|
      t.integer :user_id
      t.integer :minion_id
    end

  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

def reset_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.execute("DELETE FROM `#{table}`;")
  end
end
