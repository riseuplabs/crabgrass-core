#
# A class to transmogrify a media asset from one form to another.
#
# All such media transformations are handled by instances of this class.
#

require 'fileutils'

module Media
  class Transmogrifier

    attr_accessor :name

    attr_accessor :input
    attr_accessor :input_file
    attr_accessor :input_type

    attr_accessor :output         # maybe some day we return raw output via url?
    attr_accessor :output_type    # desired mime type of the output
    attr_accessor :output_file    # desired file location of the output

    attr_accessor :options

    attr_accessor :command_output # output of last command run

    @@verbose = true
    @@suppress_errors = false

    #
    # takes a has of options, some of which are required:
    #
    # - :input_file  or (:input and :input_type)
    # - :output_file or :output_type
    #
    def initialize(options=nil)
      self.name = self.class.to_s
      if options

        options = options.dup
        self.input       = options.delete(:input)
        self.input_file  = options.delete(:input_file)
        self.input_type  = options.delete(:input_type)
        self.output_file = options.delete(:output_file)
        self.output_type = options.delete(:output_type)
        self.options = options


        if input and input_type.nil?
          raise ArgumentError.new('input_type required if input specified')
        elsif input and input_file.nil?
          self.input_file = Media::TempFile.new(input, input_type)
        elsif input and input_file
          raise ArgumentError.new('cannot have both input and input_type')
        elsif input_file and input_type.nil?
          self.input_type = Media::MimeType.mime_type_from_extension(input_file)
        elsif input.nil? and input_file.nil?
          raise ArgumentError.new('input or input_file is required')
        end

        if output_file.nil? and output_type.nil?
          raise ArgumentError.new('output_file or output_type is required')
        elsif output_file.nil?
          self.output_file = Media::TempFile.new(nil, output_type)
        elsif output_type.nil?
          self.output_type = Media::MimeType.mime_type_from_extension(output_file)
        end

        set_temporary_outfile

      else
        #
        # this is used to register the transmogrifier.
        # we keep the list as instances instead of classes because rails
        # behaves better that way.
        #
        self.class.add(self)
      end
    end

    ##
    ## CLASS METHODS
    ##

    def self.list(); @@list ||= {}; end

    # maps mine type to an array of transmogrifiers that
    # take that type as an imput
    def self.input_map; @@input_map ||= {}; end

    # maps mine type to an array of transmogrifiers that
    # produce that type as an output
    def self.output_map; @@output_map ||= {}; end

    def self.add(trans)
      self.list[trans.name] ||= trans
    end

    #
    # returns transmogrifier class, if any, that can tranform input_type
    # into output_type
    #
    def self.find_class(input_type, output_type)
      input_transmogs = self.input_map[input_type] || []
      output_transmogs = self.output_map[output_type] || []
      # take first of the intersection, maybe add weighting in the future.
      transmog = (input_transmogs & output_transmogs).select {|tm| tm.available?}.first
      if transmog
        transmog.class
      else
        log_error 'could not find a transmogrifier for "%s" -> "%s"' % [input_type, output_type]
      end
    end

    #
    # this needs to be called once before anything will work.
    #
    def self.prepare
      # remove unavailable
      @@list.dup.each do |name, trans|
        if !trans.available?
          info('skipping transmogrifier %s, requirements not met' % trans.name, 0)
          @@list.delete(name)
        end
      end

      # set up mime type input and output maps
      @@list.each do |name, trans|
        for input_type in trans.input_types
          self.input_map[input_type] ||= []
          self.input_map[input_type] << trans
        end
        for output_type in trans.output_types
          self.output_map[output_type] ||= []
          self.output_map[output_type] << trans
        end
      end
    end

    #
    # set log verbosity
    #

    def self.verbose=(bool)
      @@verbose = bool
    end
    def self.verbose?
      @@verbose
    end

    def self.suppress_errors=(bool)
      @@suppress_errors = bool
    end
    def self.suppress_errors?
      @@suppress_errors
    end

    #
    # removes leading x- from mime-types
    #
    #def self.simple_type(mime_type)
    #  mime_type.gsub(/\/x\-/,'/') if mime_type
    #end

    ##
    ## Helpers
    ##

    #
    # runs a shell command, passing each line that is output, as it is output
    # to the block.
    #
    # returns the status of the command, as one of the following symbols:
    # :success, :failure, :not_found, :error
    #
    def run_command(*args)

      # run the command
      cmdstr = command_string(*args)
      self.command_output = ""
      IO.popen(cmdstr + ' 2>&1', 'r') do |pipe|
        while line = pipe.gets
          if block_given?
            yield(line)
          end
          self.command_output << line << "\n"
        end
      end

      # set the status
      status = case $?.exitstatus
        when 0 then :success
        when 1 then :failure
        when 127 then :not_found
        else :error
      end
      if status == :success
        log_command cmdstr
      else
        log_error cmdstr
        msg = 'exited with "%s"' % $?.exitstatus
        log_error msg
        if command_output
          log_error command_output
        end
        yield(msg) if block_given?
      end

      # restore the original output_file name
      unless restore_temporary_outfile
        msg = 'could not restore temporary outfile'
        log_error msg
        yield(msg) if block_given?
        status = :failure
      end
      return status
    end

    #def self.command_available?(command)
    #  command.present? and File.file?(command) and File.executable?(command)
    #end

    def command_available?(command)
      command and
      File.file?(command) and
      File.executable?(command)
    end

    ##
    ## PROTECTED
    ##

    protected

    def self.log(*args)
      if defined?(ActiveRecord)
        ActiveRecord::Base.logger.info "Transmogrifier --- " + args.join(' ')
      end
      info args.join(' '), 2
    end

    def self.log_error(*args)
      unless suppress_errors?
        msg = ['ERROR:'] + args
        if defined?(ActiveRecord)
          ActiveRecord::Base.logger.info "Transmogrifier --- " + msg.join(' ')
        end
        info msg.join(' '), 0
      end
    end

    def log_error(*args)
      self.class.log_error(*args)
    end

    def log(*args)
      self.class.log(*args)
    end

    def log_command(*args)
      if self.class.verbose?
        self.class.log("\tCOMMAND:", *args)
      end
    end

    #
    # returns a filename with the same base but a new extension
    #
    def replace_extension(filename, new_extension)
      old_extension = (File.extname(filename) || '').to_s
      new_extension = new_extension.to_s
      if !old_extension.empty?
        base = File.basename(filename, old_extension)
      else
        base = filename
      end
      if new_extension !~ /^\./
        new_extension = "." + new_extension
      end
      if base =~ /\.$/
        new_extension = new_extension.chomp
      end
      "#{base}#{new_extension}"
    end

    def extension(mime_type)
      Media::MimeType.extension_from_mime_type(mime_type)
    end

    #
    # usage:
    #
    #  replace_file :from => filea, :to => fileb
    #
    def replace_file(args={})
      from = args[:from].to_s
      to   = args[:to].to_s
      raise ArgumentError if from.empty? || to.empty?
      if File.exists?(from)
        if File.exists?(to)
          FileUtils.rm(to)
        end
        FileUtils.mv(from, to)
      end
    end

    ##
    ## PRIVATE
    ##

    private

    def command_string(*args)
      args.collect {|arg| shell_escape(arg.to_s)}.join(' ')
    end

    def shell_escape(str)
      if str.empty?
        "''"
      elsif str =~ %r{\A[0-9A-Za-z+_-]+\z}
        str
      else
        result = ''
        str.scan(/('+)|[^']+/) do
          if $1
            result << %q{\'} * $1.length
          else
            result << %Q{'#{$&}'}
          end
        end
        result
      end
    end

    #
    # returns true if the file as a suffix that matches the mime_type
    #
    def compatible_extension?(file, type)
      file = file.to_s
      ext = Media::MimeType.extension_from_mime_type(type)
      if ext.nil?
        return true
        # ^^ if there is no defined extension for this type, then
        # whatever the file has is fine
      else
        file_ext_type = Media::MimeType.mime_type_from_extension(file)
        return Media::MimeType.compatible_types?(type, file_ext_type)
      end
    end

    #
    # ensure that the output_file has the correct suffix
    # by setting a temporary one if the current one is not good.
    #
    def set_temporary_outfile
      @temporary_outfile = false
      if !compatible_extension?(output_file, output_type)
        @temporary_outfile = true
        @outfile_to_return = output_file
        self.output_file = Media::TempFile.new(nil, output_type)
      end
    end

    #
    # moves the current output_file to match the filename we are
    # supposed to return (which is stored in @outfile_to_return
    # by set_temporary_outfile)
    #
    def restore_temporary_outfile
      if @temporary_outfile
        replace_file :from => output_file, :to => @outfile_to_return
        self.output_file = @outfile_to_return
      end
      return true
    end

  end
end
