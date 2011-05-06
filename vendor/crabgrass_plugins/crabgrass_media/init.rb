if defined?(Rails)
  APP_TRANSMOGRIFIER_DIRECTORY    = Rails.root + 'media-transmogrifiers'
end

PLUGIN_TRANSMOGRIFIER_DIRECTORY = File.dirname(__FILE__) + '/transmogrifiers'

unless defined?(info)
  def info(msg, level); puts msg; end
end

#
# load all the transmogrifiers
#

require 'media'

info 'loading media transmogrifiers', 2

Dir.glob([PLUGIN_TRANSMOGRIFIER_DIRECTORY+'/*.rb', PLUGIN_TRANSMOGRIFIER_DIRECTORY+'/**/*.rb']).uniq.each do |file|
  info "loading #{file}", 3
  require file
end

if defined?(APP_TRANSMOGRIFIER_DIRECTORY)
  Dir.glob([APP_TRANSMOGRIFIER_DIRECTORY+'*.rb', APP_TRANSMOGRIFIER_DIRECTORY+'**/*.rb']).uniq.each do |file|
    info "loading #{file}", 3
    require file
  end
end

Media::Transmogrifier.prepare

