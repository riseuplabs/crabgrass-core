module UserRecords

  def hidden_user
    records[:hidden_user] ||= FactoryGirl.create(:user).tap do |hide|
      hide.revoke_access! friends: :view
      hide.revoke_access! peers: :view
    end
  end

  def blocking_user
    records[:blocking_user] ||= FactoryGirl.create(:user).tap do |blocking|
      blocking.revoke_access! friends: :pester
      blocking.revoke_access! peers: :pester
    end
  end

  def public_user
    records[:public_user] ||= FactoryGirl.create(:user).tap do |pub|
      pub.grant_access! public: :view
    end
  end

  def user
    records[:user] ||= FactoryGirl.create :user
  end

  def other_user
    records[:other_user] ||= FactoryGirl.create :user
  end

  def visitor
    UnauthenticatedUser.new
  end

  def friend_of(other)
    FactoryGirl.create(:user).tap do |friend|
      other.add_contact!(friend, :friend)
    end
  end

  def peer_of(other)
    FactoryGirl.create(:user).tap do |peer|
      group.add_user! other
      group.add_user! peer
    end
  end

end
