def create_fixtures
  fort = Fort.create! :name => 'fort'
  tower = Tower.create! :name => 'tower'
  me = User.create! :name => 'me'
  other = User.create! :name => 'other'
  forest_clan = Clan.create! :name => 'forest'
  hill_clan = Clan.create! :name => 'hill'

  hill_clan.users << me

  minion1 = Minion.create! :name => 'minion_of_me_1'
  minion2 = Minion.create! :name => 'minion_of_me_2'
  minion3 = Minion.create! :name => 'minion_of_other_1'

  me.minions << minion1
  me.minions << minion2
  other.minions << minion3

  # subclasses
  faction = Faction.create! :name => 'faction'
  bunker = Bunker.create! :name => 'faction'

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
