def create_fixtures
  fort = Fort.create! name: 'fort'
  tower = Tower.create! name: 'tower'
  me = User.create! name: 'me'
  other = User.create! name: 'other'
  clan_friend = User.create! name: 'friend'

  forest_clan = Clan.create! name: 'forest'
  hill_clan = Clan.create! name: 'hill'

  hill_clan.users << me
  hill_clan.users << clan_friend

  minion1 = Minion.create! name: 'minion_of_me_1'
  minion2 = Minion.create! name: 'minion_of_me_2'
  minion3 = Minion.create! name: 'minion_of_other_1'

  me.minions << minion1
  me.minions << minion2
  other.minions << minion3

  # subclasses
  faction = Faction.create! name: 'faction'
  bunker = Bunker.create! name: 'faction'
end
