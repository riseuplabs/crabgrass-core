##
## DEFINE MODELS
##

class User < ActiveRecord::Base

  has_many :allegiances
  has_many :minions, :through => :allegiances

  has_many :memberships
  has_many :clans, :through => :memberships

  def holder_codes
    {:holder => :clan, :ids => self.clan_ids}
  end

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
  has_many :allegiances
  has_many :users, :through => :allegiances

  def holder_codes
    {:holder => :minion_of_user, :ids => self.user_ids}
  end
end
class Allegiance < ActiveRecord::Base
  belongs_to :user
  belongs_to :minion
end

class Clan < ActiveRecord::Base
  has_many :memberships
  has_many :users, :through => :memberships

  #acts_as_holder
end
class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :clan
end

class UnauthenticatedUser < User
  ## we test for this in has_access? and use :public just in case
end

class Fort < ActiveRecord::Base
  acts_as_castle

  add_gate 1, :draw_bridge
  add_gate 2, :sewers, :default_open => :admin
  add_gate 3, :tunnel, :default_open => [:public, :user]
end

class Tower < ActiveRecord::Base
  acts_as_castle

  add_gate 1, :door, :default_open => true
  add_gate 2, :window

  def after_grant_access(holder, gate)
    if holder == :public
      grant_access! :admin => gate
    end
  end

  def after_revoke_access(holder, gate)
    if holder == :admin
      revoke_access! :public => gate
    end
  end
end

class Tree
end

CastleGates::Holder.define do
  add_holder 1, :user,   :model => User
  add_holder 2, :minion, :model => Minion
  add_holder 3, :clan,   :model => Clan
  add_holder 4, :minion_of_user, :association => User.associated(:minions)
  add_holder 5, :public
  add_holder 6, :admin
end
