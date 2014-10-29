##
## DEFINE MODELS
##

class User < ActiveRecord::Base
  has_many :allegiances
  has_many :minions, through: :allegiances

  has_many :memberships
  has_many :clans, through: :memberships

  # def self.current
  #   @current
  # end
  # def self.current=(value)
  #   @current = value
  # end
end

class Minion < ActiveRecord::Base
  has_many :allegiances
  has_many :users, through: :allegiances
end
class Allegiance < ActiveRecord::Base
  belongs_to :user
  belongs_to :minion
end

class Clan < ActiveRecord::Base
  has_many :memberships
  has_many :users, through: :memberships
end
class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :clan
end

class Faction < Clan
end

class UnauthenticatedUser < User
  ## we test for this in has_access? and use :public just in case
end

class Fort < ActiveRecord::Base
  #acts_as_castle
  #add_gate 1, :draw_bridge
  #add_gate 2, :sewers, :default_open => :admin
  #add_gate 3, :tunnel, :default_open => [:public, :user]
  #add_gate 4, :door, :default_open => :user
end

class Bunker < Fort
end

class Tower < ActiveRecord::Base
  #acts_as_castle
  #add_gate 1, :door, :default_open => true
  #add_gate 2, :window
  # def after_grant_access(holder, gates)
  #   if holder == :public
  #     grant_access! :admin => gates
  #   end
  # end
  # def after_revoke_access(holder, gates)
  #   if holder == :admin
  #     revoke_access! :public => gates
  #   end
  # end
end

class Tree
end

class Rabbit
end

CastleGates.define do

  castle Fort do
    gate 1, :draw_bridge
    gate 2, :sewers, default_open: :admin
    gate 3, :tunnel, default_open: :public
    gate 4, :door, default_open: :public
  end

  castle Tower do
    gate 1, :door, default_open: true
    gate 2, :window
    gate 3, :skylight

    protected

    def after_grant_access(holder, gates)
      if holder == :public
        grant_access! admin: gates
      end
    end
    def after_revoke_access(holder, gates)
      if holder == :admin
        revoke_access! public: gates
      end
    end
  end

  castle User do
    gate 1, :follow, default_open: :minion_of_user
  end

  holder 1, :user, model: User do
    def holder_codes
      [:public, {holder: :clan, ids: self.clan_ids}]
    end
  end

  holder 2, :minion, model: Minion do
    def holder_codes
      {holder: :minion_of_user, ids: self.user_ids}
    end
  end

  holder 3, :clan, model: Clan
  holder_alias :clan, model: Faction

  holder 4, :minion_of_user, association: User.associated(:minions)

  holder 0, :public
  holder_alias :public, model: Rabbit

  holder 6, :admin

  holder nil, :no_prefix_holder

end
