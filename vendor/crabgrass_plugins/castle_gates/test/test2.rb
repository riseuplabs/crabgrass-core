require 'test/unit'
require 'rubygems'
require 'ruby_debug'
require 'logger'
gem 'activerecord', '~> 2.3.0'
require 'active_record'

require "#{File.dirname(__FILE__)}/../init"

##
## OPTIONS
##

# set to true if schema changes.
REBUILD_DB = false

# set to :mysql to test aggregation BIT_OR
ADAPTER    = :sqlite

# set to true to see all the sql commands
SHOW_SQL   = false

##
## DATABASE
##

if (ADAPTER == :sqlite)
  DB_FILE = "#{File.dirname(__FILE__)}/tests2.sqlite"
  if !File.exists?(DB_FILE)
    REBUILD_DB = true
  end
  ActiveRecord::Base.establish_connection(
    :adapter  => "sqlite3",
    :database => DB_FILE
  )
else
  # if you want to test BIT_OR aggregation function
  ActiveRecord::Base.establish_connection(
    :adapter  => "mysql",
    :host => "localhost",
    :database => "castle_gates",
    :user => "root"
  )
end

#
# show all db activity
#
if SHOW_SQL
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :keys do |p|
      p.integer :castle_id
      p.string  :castle_type
      p.integer :holder_code
      p.integer :gate_bitfield, :default => 0
    end

    create_table :users do |t|
      t.column :name, :string
    end
    create_table :allegiances do |t|
      t.integer :user_id
      t.integer :minion_id
    end
    create_table :minions do |t|
      t.column :name, :string
    end

    create_table :forts do |t|
      t.column :name, :string
    end
    create_table :towers do |t|
      t.column :name, :string
    end

    # create_table :styles_users, :id => false do |t|
    #   t.integer :style_id
    #   t.integer :user_id
    # end
    # create_table :artists do |t|
    #   t.column :name, :string
    #   t.column :main_style_id, :integer
    # end
    # create_table :artists_styles, :id => false do |t|
    #   t.column :artist_id, :integer
    #   t.column :style_id, :integer
    # end
    # create_table :societies
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

##
## DEFINE MODELS
##

class User < ActiveRecord::Base
  has_many :allegiances
  has_many :minions, :through => :allegiances

  acts_as_holder

  # def self.current
  #   @current
  # end
  # def self.current=(value)
  #   @current = value
  # end
  # def access_codes
  #   self.styles.map(&:id)
  # end
end

class Minion < ActiveRecord::Base
  acts_as_holder
end

class UnauthenticatedUser < User
  ## we test for this in has_access? and use :public just in case
end

class Fort < ActiveRecord::Base
  acts_as_castle
  add_gate :id => 1, :name => :draw_bridge
  add_gate :id => 2, :name => :sewers
  
end

class Tower < ActiveRecord::Base
  acts_as_castle
  add_gate :id => 1, :name => :door
  add_gate :id => 2, :name => :window

end

User.define_holder 1
Minion.define_holder 2

#CastleGates::Holder.define :user, :id => 1, :type => User

#Holder.define :user_minions, :id => 1, :type => User        

def create_fixtures
  fort = Fort.create! :name => 'fort'
  tower = Tower.create! :name => 'tower'
  me = User.create! :name => 'me'

  #fusion = Style.create! :name => "fusion"
  #jazz = Style.create! :name => "jazz"
  #soul = Style.create! :name => "soul"
  #miles = Artist.create! :name => "Miles", :main_style => jazz
  #jazz.artists << miles
  #fusion.artists << miles
  #ella = jazz.artists.create! :name => "Ella", :main_style => jazz
  #soul.artists << ella
  #chick = fusion.artists.create! :name => "Chick", :main_style => fusion
  #me = jazz.users.create! :name => 'me'
end

##
## TEST
##

if REBUILD_DB
  teardown_db
  setup_db
  create_fixtures
end

class CastleGatesTest < Test::Unit::TestCase

  def setup
    @fort = Fort.find :first
    @tower = Fort.find :first
    @me = User.find :first
    #User.current = @me
  end

  def test_definition
    ActiveRecord::Base.transaction do
      # CastleGates::Holder.holders_by_name
      # @me.holder
      # Minion.holder
      
      assert !@fort.access?(:to => :draw_bridge, :for => @me), 'no access yet'

      @fort.grant_access! :to => :draw_bridge, :for => @me

      @fort = Fort.find :first
      assert @fort.access?(:to => :draw_bridge, :for => @me), 'should have access now'

      #p @fort.gates
      #p Tower.gate_set
      raise ActiveRecord::Rollback
    end
  end

  
end

