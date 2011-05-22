#
# This used to work using a hacky python script that connected to a running openoffice
# daemon. Now, libreoffice has a command line option to convert, so we are just going to
# use that because it is much easier.
#
# So, the daemon stuff is commented out. Maybe some day it will be useful if doing high
# volume document processing.
# 

require 'tmpdir'

unless defined?(LIBREOFFICE_COMMAND)
  cmd = `which libreoffice`.chomp
  if cmd.any?
    LIBREOFFICE_COMMAND = cmd
  else
    LIBREOFFICE_COMMAND = false
  end
end

class LibreOfficeTransmogrifier < Media::Transmogrifier

  def input_types
    %w(
      text/plain text/html text/richtext application/rtf
      text/csv text/comma-separated-values
      application/msword application/mswrite application/powerpoint
      application/excel application/access application/vnd.ms-msword
      application/vnd.ms-mswrite application/vnd.ms-powerpoint
      application/vnd.ms-excel application/vnd.ms-access
      application/msword-template application/excel-template
      application/powerpoint-template
      application/vnd.oasis.opendocument.spreadsheet
      application/vnd.oasis.opendocument.formula
      application/vnd.oasis.opendocument.chart
      application/vnd.oasis.opendocument.image
      application/vnd.oasis.opendocument.graphics
      application/vnd.oasis.opendocument.presentation
      application/vnd.oasis.opendocument.text-web
      application/vnd.oasis.opendocument.text
      application/vnd.oasis.opendocument.text-template
      application/vnd.oasis.opendocument.text-master
      application/vnd.oasis.opendocument.presentation-template
      application/vnd.oasis.opendocument.graphics-template
      application/vnd.oasis.opendocument.spreadsheet-template
      application/vnd.openxmlformats-officedocument.wordprocessingml.document
    )
  end

  def output_types
    ["application/pdf"] + input_types
  end

  def available?
    command_available?(LIBREOFFICE_COMMAND)
  end

  def run(&block)
    status = nil

    # make a unique temporary directory for output, so that the filename won't collide.
    Dir.mktmpdir do |work_directory|
      # run command
      ext = extension(output_type)
      if ext
        arguments = [LIBREOFFICE_COMMAND, '-headless', '-convert-to', extension(output_type), '-outdir', work_directory, input_file]
        status = run_command(*arguments, &block)

        # we cannot specify the name of the output file, so grab what it generated and move it to self.output_file
        libreoffice_output = work_directory + '/' + replace_extension(input_file, extension(output_type))
        replace_file :from => libreoffice_output, :to => output_file
      else
        yield('could not find extension for type %s' % output_type) if block_given?
        return :failure
      end
    end
    return status
  end

end

LibreOfficeTransmogrifier.new


#
# old daemon stuff
#


#
#require 'socket'
#
#unless defined?(PYTHON_COMMAND)
#  # TODO: pick which python to use. on some platforms, we may need to run
#  # an openoffice specific python.
#  PYTHON_COMMAND = `which python`.chomp
#end

#if LIBREOFFICE_COMMAND
#  unless defined?(LIBREOFFICE_CONVERTER_COMMAND)
#    LIBREOFFICE_CONVERTER_COMMAND = File.dirname(__FILE__) + '/od_converter.py'
#  end
#  unless defined?(LIBREOFFICE_DAEMON_PORT)
#    LIBREOFFICE_DAEMON_PORT = 8100
#  end
#  unless defined?(LIBREOFFICE_DAEMON_COMMAND)
#    LIBREOFFICE_DAEMON_COMMAND = '%s -headless -nolockcheck -nologo -norestore -accept="socket,host=127.0.0.1,port=%s;urp;tcpNoDelay=1"' % [LIBREOFFICE_COMMAND, LIBREOFFICE_DAEMON_PORT]
#  end
#end

  #cmd = `which openoffice`.chomp unless cmd.any?
  #cmd = `which openoffice.org`.chomp unless cmd.any?

#  def try_starting_daemon
#    log 'attempting to start libreoffice in daemon mode'
#    output = `#{LIBREOFFICE_DAEMON_COMMAND}`
#    if $? == 0
#      log 'libreoffice started'
#    else
#      log_error 'not able to start libreoffice'
#      log_error LIBREOFFICE_DAEMON_COMMAND
#      log_error output
#    end
#  end

#  def daemon_running?
#    begin
#      TCPSocket.new 'localhost', LIBREOFFICE_DAEMON_PORT
#      return true
#    rescue Errno::ECONNREFUSED
#      return false
#    end
#  end

#    if !daemon_running?
#      try_starting_daemon
#      sleep 1
#      if !daemon_running?
#        return :error
#      end
#    end
#    arguments = [PYTHON_COMMAND, LIBREOFFICE_CONVERTER_COMMAND, input_file, output_file]

