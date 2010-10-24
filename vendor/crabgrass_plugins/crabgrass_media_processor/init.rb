require 'media/process.rb'

module Media::Process
  GM_COMMAND = `which gm`.chomp
  PYTHON_COMMAND   = `which python`.chomp
  FFMPEG_COMMAND   = `which ffmpeg`.chomp
  INKSCAPE_COMMAND = `which inkscape`.chomp
  OPENOFFICE = `which openoffice`.chomp.any || `which openoffice.org`.chomp.any
  if OPENOFFICE
    OPENOFFICE_DAEMON_PORT = 8100
    OPENOFFICE_COMMAND = File.dirname(__FILE__) + '/bin/od_converter.py'
    OPENOFFICE_DAEMON_COMMAND = '%s -headless -accept="socket,port=%s;urp;"' % [OPENOFFICE, OPENOFFICE_DAEMON_PORT]
  else
    OPENOFFICE_COMMAND = nil
  end
end

