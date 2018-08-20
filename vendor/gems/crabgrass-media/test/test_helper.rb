require 'minitest/autorun'
require 'media'
require 'logger'

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

Media::TMP_PATH = '/tmp'

LOGPATH = "#{File.dirname(__FILE__)}/../log"
FileUtils.mkdir(LOGPATH) unless File.exist? LOGPATH
LOGFILE = "#{LOGPATH}/transmogrifier.log"
Media::Transmogrifier.logger = Logger.new(LOGFILE)
