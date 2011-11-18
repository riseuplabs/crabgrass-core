#
# transform data for dismod
# requires /usr/local/sbin/computation_manager_stub.py
#

unless defined?(DISMOD_COMMAND)
  DISMOD_COMMAND = '/usr/local/sbin/computation_manager_stub.py'
end

class DismodTransmogrifier < Media::Transmogrifier

  def input_types
    %w( application/dismod-input )
  end

  def output_types
    %w( application/dismod-output )
  end

  def available?
    DISMOD_COMMAND.any? and File.exists?(DISMOD_COMMAND)
  end

  #
  # dismod takes an input file and output file:
  # $ computation_manager_stub.py infile.txt outfile.txt
  # dismod prints progress info to stdout
  #
  def run(&block)
    arguments = [DISMOD_COMMAND, input_file, output_file]
    run_command(*arguments, &block)
  end

end

DismodTransmogrifier.new

