# (this file is prefixed with z_, so it's loaded last)

#if defined?(User)
  #
  # This needs to be run last, after models are loaded. Sometimes, environment.rb is loaded
  # without models getting loaded. Hence, the defined?(User) test around this block.
  # It is hackish, but it works.
  #
  ## FIXME: the hack described in the comment above didn't work anymore after moving to rails3.
  CastleGates.initialize('config/permissions')
#end
