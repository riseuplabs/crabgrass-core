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

REBUILD_DB = false     # set to true if schema changes.

ADAPTER    = :sqlite   # set to :mysql to test aggregation BIT_OR

SHOW_SQL   = false     # set to true to see all the sql commands

##
## DATABASE
##



if (ADAPTER == :sqlite)
  DB_FILE = "#{File.dirname(__FILE__)}/tests.sqlite"
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
    create_table :styles do |t|
      t.column :name, :string
    end
    create_table :users do |t|
      t.column :name, :string
    end
    create_table :styles_users, :id => false do |t|
      t.integer :style_id
      t.integer :user_id
    end
    create_table :artists do |t|
      t.column :name, :string
      t.column :main_style_id, :integer
    end
    create_table :artists_styles, :id => false do |t|
      t.column :artist_id, :integer
      t.column :style_id, :integer
    end
    create_table :societies
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

##
## DEFINE MODELS
##

class User < ActiveRecord::Base
  has_and_belongs_to_many :styles
  def self.current
    @current
  end
  def self.current=(value)
    @current = value
  end

  def access_codes
    self.styles.map(&:id)
  end
end

class UnauthenticatedUser < User
  # we test for this in has_access? and use :public just in case
end

class Artist < ActiveRecord::Base
  belongs_to :main_style, :class_name => "Style"
  has_and_belongs_to_many :styles
  def holder_code; 100 + id; end
end

class Style < ActiveRecord::Base
  has_and_belongs_to_many :artists
  has_and_belongs_to_many :users
  alias_method :holder_code, :id
  # let's define the different locks
  acts_as_castle :see, :hear, :dance
  CastleGates::Key.resolve_holder :style
end

# some locked class with other keys
class Society < ActiveRecord::Base
  acts_as_castle :publish, :play, :sing
end

def create_fixtures
  fusion = Style.create! :name => "fusion"
  jazz = Style.create! :name => "jazz"
  soul = Style.create! :name => "soul"
  miles = Artist.create! :name => "Miles", :main_style => jazz
  jazz.artists << miles
  fusion.artists << miles
  ella = jazz.artists.create! :name => "Ella", :main_style => jazz
  soul.artists << ella
  chick = fusion.artists.create! :name => "Chick", :main_style => fusion
  me = jazz.users.create! :name => 'me'
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
    @fusion = Style.find_by_name "fusion"
    @jazz   = Style.find_by_name "jazz"
    @soul   = Style.find_by_name "soul"
    @miles  = Artist.find_by_name "Miles"
    @ella   = Artist.find_by_name "Ella"
    @chick  = Artist.find_by_name "Chick"
    @me     = User.find_by_name 'me'
    User.current = @me
  end

  def teardown
  end

  def test_key_functions
    ActiveRecord::Base.transaction do
      @fusion.grant! @soul, :dance
      @fusion.grant! @jazz, [:hear, :see]
      assert @fusion.has_access?(:hear), "fusion should allow me to hear as I am a jazz user."
      assert !@fusion.has_access?(:dance), "fusion should not allow me to dance as I am not a soul user."
      # I'm a soul user now
      @soul.users << @me
      @me.reload
      @fusion.reload
      assert @fusion.has_access?([:dance, :hear, :see]), "combining access from different holders should work."
      raise ActiveRecord::Rollback     
    end
  end

  def test_getting_keys_per_lock
    ActiveRecord::Base.transaction do
      soul_key = @fusion.grant! @soul, [:dance, :hear]
      jazz_key = @fusion.grant! @jazz, [:hear, :see]
      expected = {
        :hear => [soul_key, jazz_key],
        :see => [jazz_key],
        :dance => [soul_key]}
      assert_equal expected, @fusion.keys_by_lock
      raise ActiveRecord::Rollback
    end
  end

  def test_setting_holders_per_lock
    ActiveRecord::Base.transaction do
      @fusion.grant! @soul, :dance
      @fusion.grant! :hear => [@soul, @jazz],
        :see => @jazz
      assert @fusion.has_access?(:hear), "fusion should allow me to hear as I am a jazz user."
      assert !@fusion.has_access?(:dance), "fusion should not allow me to dance as I am not a soul user."
      # I'm a soul user now
      @soul.users << @me
      @me.reload
      @fusion.reload
      assert @fusion.has_access?([:dance, :hear, :see]), "combining access from different holders should work."
      raise ActiveRecord::Rollback     
    end
  end

  def test_locks_in_different_class
    ActiveRecord::Base.transaction do
      @brave_new = Society.create!
      @brave_new.grant! @jazz, :publish
      assert @brave_new.has_access?(:publish), "the publish key should work for society"
      assert_raises CastleGates::LockError do
        @brave_new.grant! @jazz, :see
      end
      assert_raises CastleGates::LockError do
        @soul.grant! @jazz, :publish
      end
      raise ActiveRecord::Rollback     
    end
  end

  def test_locks_with_different_holder_types
    ActiveRecord::Base.transaction do
      CastleGates::Key.resolve_holder do |code|
        code > 100 ?
          Artist.find(code -100) :
          Style.find(code)
      end
      soul_key = @jazz.grant! @soul, :see
      miles_key = @jazz.grant! @miles, [:see, :dance]
      expected = {
        :see => [soul_key, miles_key],
        :dance => [miles_key]}
      assert_equal expected, @jazz.keys_by_lock
      CastleGates::Key.resolve_holder :style
      raise ActiveRecord::Rollback     
    end
  end


  def test_locks_with_symbolic_holders
    ActiveRecord::Base.transaction do
      with_symbol_codes do
        admin_key = @jazz.grant! :admin, [:see, :dance]
        soul_key = @jazz.grant! @soul, :see
        miles_key = @jazz.grant! @miles, :hear

        expected = {
          :see => [admin_key, soul_key],
          :dance => [admin_key],
          :hear => [miles_key]}

        assert_equal expected, @jazz.keys_by_lock
      end
      raise ActiveRecord::Rollback     
    end
  end

  def test_invalid_symbolic_holder
    ActiveRecord::Base.transaction do
      with_symbol_codes do
        assert_raises CastleGates::LockError do
          @jazz.grant! :foo, [:see, :dance]
        end
      end
      raise ActiveRecord::Rollback     
    end
  end

  def test_dependencies
    ActiveRecord::Base.transaction do
      with_symbol_codes do
        with_dependencies do
          admin_key = @jazz.grant! :admin, [:hear]
          public_key = @jazz.grant! :public, [:see, :dance]
          expected = {
            :see => [admin_key, public_key],
            :dance => [admin_key, public_key],
            :hear => [admin_key]}
          assert_equal expected, @jazz.keys_by_lock

          admin_key = @jazz.revoke! :admin, [:see, :hear]
          assert_equal expected.slice(:dance), @jazz.reload.keys_by_lock
        end
      end
      raise ActiveRecord::Rollback     
    end
  end

  ##
  ## TODO -- I don't understand this test.
  ## 
  def xxxxxtest_query_caching
    ActiveRecord::Base.transaction do
      # all @jazz users may see @jazz
      @jazz.grant! @jazz, :see
      artists = Artist.find :public, :include => {:main_style => :current_user_keys}
      # we remove the permission but it has already been cached...
      assert @jazz.has_access?(:see), ":see should be allowed to current_user."
      @jazz.revoke!(@jazz, :see)
      @jazz.reload
      assert !@jazz.has_access?(:see), "the :see key should have been revoked."
      assert_equal @miles, artists.first
      assert artists.first.main_style.has_access?(:see), "artists should have cached the permission."
      raise ActiveRecord::Rollback     
    end
  end

  def test_adding_lock_symbols
    ActiveRecord::Base.transaction do
      assert_raises CastleGates::LockError do
        @jazz.grant! @jazz, :do_crazy_things
      end
      Style.add_locks :do_crazy_things
      @jazz.grant! @jazz, :do_crazy_things
      assert @jazz.has_access?(:do_crazy_things), "I should be able to add keys in different places"
      @jazz.grant! @jazz, :see
      @jazz.reload
      assert @jazz.has_access?([:see, :do_crazy_things]), "Old keys should work with new ones."
      raise ActiveRecord::Rollback     
    end
  end



  ## INTERNALS
  #
  #  tests that access internal structures of the implementation
  #  Please use the functions called in the tests above instead.
  #

  def test_bit_mask
    ActiveRecord::Base.transaction do
      Style.add_locks :do_crazy_things
      @fusion.grant! @soul, :do_crazy_things
      k = @fusion.keys.find_by_holder_code(@soul.holder_code)
      assert_equal 8, k.gate_bitfield
      p = @fusion.grant! @jazz, [:see, :dance, :do_crazy_things]
      p = @fusion.keys.find_by_holder_code(@jazz.holder_code)
      assert_equal 13, p.gate_bitfield
      raise ActiveRecord::Rollback     
    end
  end


  ## HELPER FUNCTIONS
  #
  # factored out of the tests for sake of simple tests
  #

  def with_symbol_codes
    CastleGates::Key.symbol_codes = {
      :public => 500,
      :admin => 501,
      :other => 502
    }
    CastleGates::Key.resolve_holder do |code|
      case code
      when 1...100
        Style.find(code)
      when 100...200
        Artist.find(code -100)
      when 500...510
        CastleGates::Key.symbol_for(code)
      end
    end

    yield

    CastleGates::Key.resolve_holder :style
    CastleGates::Key.symbol_codes = {}
  end

  def with_dependencies
    Style.class_eval do
      def grant_dependencies(key)
        if key.holder == :public
          self.grant! :admin, key.locks
        end
      end

      def revoke_dependencies(key)
        if key.holder == :admin
          self.revoke! :public, key.locks(:disabled => :true)
        end
      end
    end

    yield

    Style.class_eval do
      undef grant_dependencies
      undef revoke_dependencies
    end
  end

end

