require 'test/unit'
require 'rubygems'
require 'ruby_debug'
require 'logger'
gem 'activerecord', '~> 2.3.0'
require 'active_record'

##
## OPTIONS
##

#
# run like so to specify arguments:
#
#   ruby test/tests.rb -- --rebuild
#

# set to true if schema changes.
REBUILD_DB = ARGV.grep('--rebuild').any?

# set to true if fixtures changes.
RELOAD_FIXTURES = ARGV.grep('--reload').any?

# set to :mysql to test aggregation BIT_OR
ADAPTER = :sqlite

# set to true to see all the sql commands
SHOW_SQL = false #true

##
## TEST HELPERS
##

['../init', 'setup_db', 'models', 'fixtures'].each do |file|
  require "#{File.dirname(__FILE__)}/" + file
end

if REBUILD_DB
  teardown_db
  setup_db
  create_fixtures
elsif RELOAD_FIXTURES
  reset_db
  create_fixtures
end

##
## TEST
##

class CastleGatesTest < Test::Unit::TestCase

  def setup
    @fort = Fort.find :first
    @tower = Tower.find :first
    @me = User.find :first
    @other = User.find :last
    @hill_clan = Clan.find_by_name 'hill'
    @forest_clan = Clan.find_by_name 'forest'
    #User.current = @me
  end

  def test_argument_exception
    assert_raises ArgumentError do
      @fort.grant_access!(Tree.new => :draw_bridge)
    end
    assert_raises ArgumentError do
      @fort.grant_access!(:not_a_holder => :draw_bridge)
    end
    assert_raises ArgumentError do
      @fort.grant_access!(:public => :not_a_gate)
    end
  end

  def test_simple_grant
    ActiveRecord::Base.transaction do
      assert !@fort.access?(@me => :draw_bridge), 'no access yet'

      @fort.grant_access!(@me => :draw_bridge)
      assert @fort.access?(@me => :draw_bridge), 'should have access now'

      assert !@fort.access?(@me => :sewers), 'should NOT have access to other gates'
      assert !@fort.access?(@other => :draw_bridge), 'only @me should have access'

      assert !@tower.access?(@me => :window), 'should not have access to other castles'

      raise ActiveRecord::Rollback
    end
  end

  def test_indirect_grant
    ActiveRecord::Base.transaction do
      assert !@fort.access?(@me => :draw_bridge), 'no access yet'

      # grant to clan i am not in
      @fort.grant_access!(@forest_clan => :draw_bridge)
      assert !@fort.access?(@me => :draw_bridge), 'i am not in the forest clan'

      # grant to clan i am in
      @fort.grant_access!(@hill_clan => :draw_bridge)
      assert @fort.access?(@me => :draw_bridge), 'should have access now'

      raise ActiveRecord::Rollback
    end
  end

  def test_symbolic_grant
    ActiveRecord::Base.transaction do
      assert !@fort.access?(:public => :draw_bridge), 'no access yet'

      @fort.grant_access!(:public => :draw_bridge)
      assert @fort.access?(:public => :draw_bridge), 'should have access now'

      assert !@fort.access?(:public => :sewers), 'but not to other gates'
      assert !@fort.access?(@me => :draw_bridge), 'and others should not'
      assert !@tower.access?(:public => :window), 'should not have access to other castles'

      raise ActiveRecord::Rollback
    end
  end

  def test_association_holders
    ActiveRecord::Base.transaction do
      assert !@fort.access?(@me.associated(:minions) => :draw_bridge), 'no access yet'
      @fort.grant_access!(@me.associated(:minions) => :draw_bridge)

      assert @fort.access?(@me.associated(:minions) => :draw_bridge), 'should have access now'
      assert @fort.access?(@me.minions.first => :draw_bridge), 'should have access now'
      assert !@fort.access?(@other.minions.first => :draw_bridge), 'others should NOT have access'
      raise ActiveRecord::Rollback
    end
  end

  def test_multivalue_arguments
    ActiveRecord::Base.transaction do
      @fort.grant_access!([:public, @me] => [:draw_bridge, :sewers])
      assert @fort.access? :public => :draw_bridge
      assert @fort.access? :public => :sewers
      assert @fort.access? @me => :draw_bridge
      assert @fort.access? @me => :sewers
      raise ActiveRecord::Rollback
    end
  end

  def test_revoke
    ActiveRecord::Base.transaction do
      @fort.grant_access!(@me => :draw_bridge)
      assert @fort.access?(@me => :draw_bridge), 'should have access now'
      @fort.revoke_access!(@me => :draw_bridge)
      assert !@fort.access?(@me => :draw_bridge), 'should NOT have access now'
      raise ActiveRecord::Rollback
    end
  end

  def test_after_grant_access
    ActiveRecord::Base.transaction do
      @tower.grant_access!(:public => :window)
      assert @tower.access?(:admin => :window)
      @tower.revoke_access!(:admin => :window)
      assert !@tower.access?(:public => :window)
      raise ActiveRecord::Rollback
    end
  end

  def test_global_defaults
    ActiveRecord::Base.transaction do
      assert @tower.access?(:public => :door), 'default should be open'
      assert @tower.access?(@me => :door), 'default should be open'
      assert !@tower.access?(:public => :window), 'but not the window'

      @tower.grant_access!(:public => :window)
      assert @tower.access?(:public => :window), 'now the window'
      assert @tower.access?(:public => :door), 'still the door'

      @tower.revoke_access!(:public => :window)
      assert !@tower.access?(:public => :window), 'not the window, again'
      assert @tower.access?(:public => :door), 'still the door'

      @tower.revoke_access!(:public => :door)
      assert !@tower.access?(:public => :door), 'explicit revoke should remove access'
      raise ActiveRecord::Rollback
    end
  end

  def test_holder_specific_defaults
    ActiveRecord::Base.transaction do
      assert @fort.access?(:admin => :sewers), 'default should be open for :admin'
      assert @fort.access?(@me => :tunnel), 'default should be open for @me'
      @fort.revoke_access!(:admin => :sewers)
      assert !@fort.access?(:admin => :sewers), 'default should get overridden'
      raise ActiveRecord::Rollback
    end
  end

  def test_finder
    ActiveRecord::Base.transaction do
      assert_nil Fort.with_access(:public => :draw_bridge).first
      @fort.grant_access! :public => :draw_bridge
      assert_equal [@fort], Fort.with_access(:public => :draw_bridge)

      assert_nil Fort.with_access(@me => :draw_bridge).first
      assert_nil Fort.with_access(:public => :sewers).first

      @fort.grant_access! @me => :draw_bridge
      assert_equal [@fort], Fort.with_access(@me => :draw_bridge)

      @fort2 = Fort.create :name => 'fort2'
      @fort2.grant_access! @me => :draw_bridge
      assert_equal 2, Fort.with_access(@me => :draw_bridge).count

      assert_raises ArgumentError do
        Fort.with_access(:public => :x)
      end
      assert_raises ArgumentError do
        Fort.with_access(:x => :draw_bridge)
      end

      raise ActiveRecord::Rollback
    end
  end

  def test_x
    ActiveRecord::Base.transaction do

      raise ActiveRecord::Rollback
    end
  end

end

