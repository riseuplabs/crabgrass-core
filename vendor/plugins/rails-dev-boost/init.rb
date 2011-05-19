
#
# crabgrass changes: guard with ENV['BOOST'] and added info() call.
#

if ENV['BOOST']
  if !$rails_rake_task && (Rails.env.development? || (config.respond_to?(:soft_reload) && config.soft_reload))
    require 'rails_development_boost'
    RailsDevelopmentBoost.apply!
    info 'rails dev boost activated'
  end
end
