##
## Symbols for access
##

ActsAsLocked::Key.symbol_codes = {
  :public => 0,  # visible to search engines and other bots
  :visitors => 1  # visible without login but not for robots
}

##
## Number codes to entities
##

ActsAsLocked::Key.resolve_holder do |code|
  if code < 10
    ActsAsLocked::Key.symbol_for(code)
  else
    string = code.to_s
    prefix = string.first
    id = string[1..-1].to_i
    case prefix.to_i
    when 1
      User.find(id)
    when 5
      Site.find(id)
    when 7
      User.find(id).friends
    when 8
      Group.find(id)
    when 9
      User.find(id).peers
    end
  end
end
