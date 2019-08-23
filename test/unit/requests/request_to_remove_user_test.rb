require 'test_helper'

class RequestToRemoveUserTest < ActiveSupport::TestCase
  :castle_gates_keys

  def setup
    # 6 in total users in rainbow:
    # ["blue", "orange", "purple", "yellow", "red", "green"]
    @group     = groups(:rainbow)
    @user      = users(:orange)
    @requester = users(:red)
  end

  def test_remove_request_fails
    def @requester.longterm_member_of?(group)
      false
    end
    assert_raises ActiveRecord::RecordInvalid, 'Permission Denied' do
      @request = RequestToRemoveUser.create! created_by: @requester, group: @group, user: @user
    end
    assert_not_removed
  end

  def test_remove_succeeds
    def @requester.longterm_member_of?(group)
      true
    end
    @approver = users(:green)
    def @approver.longterm_member_of?(group)
      true
    end
    @request = RequestToRemoveUser.create! created_by: @requester, group: @group, user: @user
    @request.approve_by!(@approver)
    assert_equal 'approved', @request.state, 'state should change'
    assert_removed
  end

  def test_remove_fails
    def @requester.longterm_member_of?(group)
      true
    end
    @approver = users(:green)
    def @approver.longterm_member_of?(group)
      false
    end
    @request  = RequestToRemoveUser.create! created_by: @requester, group: @group, user: @user
    @approver = users(:green)
    assert_raises PermissionDenied do
      @request.approve_by!(@approver)
    end
    assert_equal 'pending', @request.state, 'state should not change'
    assert_not_removed
  end

  #   def test_voting_on_request
  #     @request.approve_by!(users(:green))
  #     assert_equal 'pending', @request.state, 'state should not change'
  #   end
  #
  #   def test_single_approval
  #     @request.approve_by!(users(:green))
  #     pretend_we_are_in_the_future!
  #       @request.tally!
  #       assert_approved
  #     reset_time_to_present!
  #   end
  #
  #   # 1 approval, 3 rejections
  #   def test_instant_rejection
  #     @request.approve_by!(users(:green))
  #
  #     @request.reject_by!(users(:blue))
  #     @request.reject_by!(users(:orange))
  #     @request.reject_by!(users(:purple))
  #
  #     assert_rejected
  #   end
  #
  #   def test_delayed_approval
  #     @request.approve_by!(users(:green))
  #     @request.approve_by!(users(:blue))
  #     @request.reject_by!(users(:purple))
  #
  #     pretend_we_are_in_the_future!
  #       @request.tally!
  #       assert_approved
  #     reset_time_to_present!
  #   end
  #
  #   def test_delayed_rejection
  #     @request.approve_by!(users(:green)) # tie
  #     @request.reject_by!(users(:purple)) #
  #
  #     pretend_we_are_in_the_future!
  #       @request.tally!
  #       assert_rejected
  #     reset_time_to_present!
  #   end
  #
  #   #
  #   # this is an awefully slow test
  #   #
  #   def test_voting_scenarios
  #     voting_scenarios.each do |scenario|
  #       request = RequestToRemoveUser.create! :created_by => users(:red), :recipient => groups(:rainbow), :requestable => users(:blue)
  #
  #       # blue should never vote, because vote by user proposed for deletion is treated differently
  #       users = @group.users.clone.select {|u| u.id != users(:blue).id}
  #
  #       # do the votes
  #       scenario[:reject].times do
  #         user = users.shift
  #         request.reject_by!(user)
  #       end
  #       scenario[:approve].times do
  #         user = users.shift
  #         request.approve_by!(user)
  #       end
  #
  #       # check that the specified outcome happened
  #       if scenario[:instant]
  #         assert_equal scenario[:instant], request.state, "On scenario: #{scenario.inspect}"
  #         if request.state == 'approved'
  #           @group.add_user!(users(:blue))
  #         end
  #       else
  #         assert_equal 'pending', request.state, "On scenario: #{scenario.inspect}"
  #         pretend_we_are_in_the_future!
  #           request.tally!
  #           assert_equal scenario[:delayed], request.state, "On scenario: #{scenario.inspect}"
  #           if request.state == 'approved'
  #             @group.add_user!(users(:blue))
  #           end
  #         reset_time_to_present!
  #       end
  #
  #       request.destroy
  #     end
  #
  #   end
  #
  #   def pretend_we_are_in_the_future!
  #     # we don't have mocha and minitest does not support stubbing
  #     # Time.stubs(:now).returns(future_time)
  #     return if Time.respond_to? :now_with_stubbing
  #     Time.class_eval do
  #       class << self
  #         def now_with_stubbing
  #           now_without_stubbing + 2.months
  #         end
  #
  #         alias_method_chain :now, :stubbing
  #       end
  #     end
  #   end
  #
  #   def reset_time_to_present!
  #     # we don't have mocha and minitest does not support stubbing
  #     # teardown_stubs
  #     Time.class_eval do
  #       class << self
  #         alias_method :now, :now_without_stubbing
  #         undef :now_with_stubbing
  #       end
  #     end
  #   end

  protected

  #   def voting_scenarios
  #     [
  #       # 0 rejections
  #       {:approve => 0, :reject => 0, :delayed => 'approved'},
  #       {:approve => 1, :reject => 0, :delayed => 'approved'},
  #       {:approve => 2, :reject => 0, :delayed => 'approved'},
  #
  #       {:approve => 3, :reject => 0, :instant => 'approved'},
  #       {:approve => 4, :reject => 0, :instant => 'approved'},
  #       {:approve => 5, :reject => 0, :instant => 'approved'},
  #
  #       # 1 rejections
  #       {:approve => 0, :reject => 1, :delayed => 'rejected'},
  #       {:approve => 1, :reject => 1, :delayed => 'rejected'},
  #       {:approve => 2, :reject => 1, :delayed => 'approved'},
  #       {:approve => 3, :reject => 1, :delayed => 'approved'},
  #
  #       {:approve => 4, :reject => 1, :instant => 'approved'},
  #
  #       # 2 rejections
  #       {:approve => 0, :reject => 2, :delayed => 'rejected'},
  #       {:approve => 1, :reject => 2, :delayed => 'rejected'},
  #       {:approve => 2, :reject => 2, :delayed => 'rejected'},
  #       {:approve => 3, :reject => 2, :delayed => 'approved'},
  #
  #       # 3 rejections
  #       {:approve => 0, :reject => 3, :instant => 'rejected'},
  #       {:approve => 1, :reject => 3, :instant => 'rejected'},
  #       {:approve => 2, :reject => 3, :instant => 'rejected'},
  #
  #       # 4 rejections
  #       {:approve => 0, :reject => 4, :instant => 'rejected'},
  #       {:approve => 1, :reject => 4, :instant => 'rejected'},
  #
  #       # 5 rejections
  #       {:approve => 0, :reject => 5, :instant => 'rejected'}
  #     ]
  #   end
  #
  #   def assert_rejected
  #     assert_equal 'rejected', @request.state, 'should be rejected'
  #     assert @group.users(true).include?(@user), 'group should NOT have orange'
  #   end
  #
  #   def assert_approved
  #     assert_equal 'approved', @request.state, 'should be approved'
  #     assert !@group.users(true).include?(@user), 'group should still have orange'
  #   end

  def assert_removed
    assert !@group.users.reload.include?(@user), 'group should NOT have orange'
  end

  def assert_not_removed
    assert @group.users.reload.include?(@user), 'group should still have orange'
  end
end
