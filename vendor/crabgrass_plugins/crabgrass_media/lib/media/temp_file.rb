require 'tempfile'
require 'fileutils'
require 'pathname'

#
# media processing requires a different type of tempfile... because we use command
# line tools to process our temp files, these files can't be open and closed by ruby.
#
# instead, Media::TempFile is used to generate closed files from binary data (for files
# to be fed to command line tools), or to generate empty tmp files (for output filenames
# to be fed to command line tools).
#
# We use the Tempfile class for generating these files, but then we always close them
# right away. By doing this, we ensure that the temp file will eventually get removed
# when the Tempfile gets garbage collected.
#

unless defined?(MEDIA_TMP_PATH)
  if defined?(Rails)
    MEDIA_TMP_PATH = File.join(Rails.root, 'tmp', 'media')
  else
    MEDIA_TMP_PATH = File.join('', 'tmp', 'media')
  end
end

module Media
  class TempFile

    def self.tempfile_path
      MEDIA_TMP_PATH
    end

    ##
    ## INSTANCE METHODS
    ##

    public

    #
    # data may be one of:
    #
    #  - FileUpload object: like the kind returned in multibyte encoded file upload forms.
    #  - Pathname object: then load data from the file pointed to by the pathname.
    #  - IO object: read the contents of the io object, copy to tmp file.
    #  - otherwise, dump the contents of the data to the tmp file.
    #
    # if data is empty, we generate an empty one.
    #
    def initialize(data, content_type=nil)
      if data.nil?
        @tmpfile = TempFile.create_from_content_type(content_type)
      elsif data.respond_to?(:path)
        # we are dealing with an uploaded file object
        @tmpfile = TempFile.create_from_file(data.path, content_type, {mode: :move})
      elsif data.is_a?(StringIO)
        data.rewind
        @tmpfile = TempFile.create_from_data(data.read, content_type)
      elsif data.instance_of?(Pathname)
        @tmpfile = TempFile.create_from_file(data.to_s, content_type)
      else
        @tmpfile = TempFile.create_from_data(data, content_type)
      end
    end

    #
    # like initialize, but if given a block, then it yields the TempFile
    # and also unlinks the file at the end of the block.
    #
    def self.open(data, content_type=nil)
      tmp = TempFile.new(data, content_type)
      if block_given?
        begin
          yield tmp
        ensure
          tmp.clear
        end
        nil
      else
        tmp
      end
    end

    def clear
      # this is not really needed, because the tmp files are deleted as soon as
      # @tmpfile gets garbage collected.
      # @tmpfile.unlink
    end

    def any?
      @tmpfile.any?
    end

    def path
      @tmpfile.path
    end

    def to_s
      @tmpfile.path
    end

    ##
    ## CLASS METHODS
    ##

    private

    #
    # creates a tempfile filled with the given binary data
    #
    def self.create_from_data(data, content_type=nil)
      tf = Tempfile.new(content_type_basename(content_type), tempfile_path)
      tf.binmode
      tf.write(data)
      tf.close
      tf
    end

    #
    # create an empty temp file with an extension to match the content_type
    #
    def self.create_from_content_type(content_type)
      tf = Tempfile.new(content_type_basename(content_type), tempfile_path)
      tf.close
      tf
    end

    #
    # create a tmp file that is a copy of another file.
    #
    def self.create_from_file(filepath, content_type, options = {})
      tf = Tempfile.new(content_type_basename(content_type), tempfile_path)
      tf.close
      if options[:mode] == :move
        FileUtils.mv filepath, tf.path
      else
        FileUtils.cp filepath, tf.path
      end
      tf
    end

    #
    # create a filename with a file extension from the content_type
    #
    def self.content_type_basename(content_type)
      if content_type
        extension = Media::MimeType.extension_from_mime_type(content_type) || 'bin'
        ['media_temp_file', extension]
      else
        'media_temp_file'
      end
    end

  end
end

FileUtils.mkdir_p(Media::TempFile.tempfile_path) unless File.exists?(Media::TempFile.tempfile_path)

