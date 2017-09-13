#
# Asset::Storage
#
# Code to handle the backend file storage for asset models.
#

require 'fileutils'

module Asset::Storage
  def self.included(base) #:nodoc:
    base.before_update :rename_file
    base.after_destroy :destroy_file
  end

  def self.make_required_dirs
    Path.private_storage.mkpath unless Path.private_storage.exist?
    Path.public_storage.mkpath unless Path.public_storage.exist?
  end

  ##
  ## ASSET PATHS
  ##

  delegate :private_filename, :public_filename, to: :path

  # return a list of all the files that are associated with this asset
  # including thumbnails, but not versions. This list is used to remove
  # old files after a new version is uploaded.
  def all_filenames
    files = []
    if filename
      files << private_filename
      thumbdefs.each do |_name, thumbdef|
        files << private_filename(thumbnail_filename(thumbdef))
      end
    end
    files
  end

  ##
  ## override attributes
  ##

  # Sets a new filename.
  def filename=(value)
    @path = nil
    write_attribute :filename, sanitize_filename(value)
  end

  # Sets a new base filename, without changing the extension
  def base_filename=(value)
    return unless value
    value += ext if read_attribute(:filename) and !value.ends_with?(ext)
    self.filename = value
  end

  # create a hard link between the files for orig_model
  # and the files for self (which are in a versioned directory)
  def clone_files_from(orig_model)
    if is_version? and filename
      hard_link orig_model.private_filename, private_filename
      thumbdefs.each do |_name, thumbdef|
        thumbnail_filename = thumbnail_filename(thumbdef)
        hard_link orig_model.private_filename(thumbnail_filename),
                  private_filename(thumbnail_filename)
      end
    end
  end

  def hard_link(source, dest)
    FileUtils.mkdir_p(File.dirname(dest))
    FileUtils.ln(source, dest) if File.exist?(source) and !File.exist?(dest)
  end

  protected

  ##
  ## file management
  ##

  # Destroys the all files for this asset.
  def destroy_file
    if is_version?
      # just remove version directory
      FileUtils.rm_rf(File.dirname(private_filename)) if File.exist?(File.dirname(private_filename))
      #      elsif is_thumbnail?
      #        # just remove thumbnail
      #        FileUtils.rm(private_filename) if File.exists?(private_filename)
    else
      # remove everything
      remove_symlink
      FileUtils.rm_rf(File.dirname(private_filename)) if File.exist?(File.dirname(private_filename))
    end
  end

  #
  # renames the stored file if the self.filename attribute has changed.
  # called as before_update callback.
  #
  def rename_file
    if filename_changed? and !new_record? and !uploaded_data_changed?
      Dir.chdir(File.dirname(private_filename)) do
        FileUtils.mv filename_was, filename
      end
    end
  end

  # Saves the file to the file system
  def save_to_storage(temp_path)
    if File.exist?(temp_path)
      FileUtils.mkdir_p(File.dirname(private_filename))
      FileUtils.cp(temp_path, private_filename)
      File.chmod(0o644, private_filename)
    end
    true
  end

  def current_data
    File.file?(private_filename) ? File.read(private_filename) : nil
  end

  def symlink_missing?
    public? and !has_symlink?
  end
  public :symlink_missing?

  def has_symlink?
    File.exist?(File.dirname(public_filename))
  end

  # creates a symlink from the private asset storage to a publicly accessible directory
  def add_symlink
    unless has_symlink?
      real_private_path = Pathname.new(private_filename).realpath.dirname
      real_public_path  = Path.public_storage.realpath
      public_to_private = real_private_path.relative_path_from(real_public_path)
      real_public_path += path.id.to_s
      # puts "FileUtils.ln_s(#{public_to_private}, #{real_public_path})"
      FileUtils.ln_s(public_to_private, real_public_path)
    end
  end

  # removes symlink from public directory
  def remove_symlink
    FileUtils.rm(File.dirname(public_filename)) if has_symlink?
  end

  ##
  ## Utility
  ##

  def sanitize_filename(filename)
    return unless filename
    filename.strip.tap do |name|
      # NOTE: File.basename doesn't work right with Windows paths on Unix
      # get only the filename, not the whole path
      name.gsub! /^.*(\\|\/)/, ''

      # strip out ' and "
      # name.gsub! /['"]/, ''

      # keep:
      #  alphanumeric characters
      #  hypen
      #  space
      #  period
      # name.gsub! /[^\w\.\ ]+/, '-'

      # don't allow the thumbnail separator
      name.gsub! /#{THUMBNAIL_SEPARATOR}/, ' '

      # remove weird constructions:
      # - trailing or leading hypen
      # - hypen-space or hypen-period
      # - duplicate spaces
      name.gsub! /^\-|\-$|/, ''
      name.gsub! /\-\.|\.\-/, '.'
      name.gsub! /\-\ |\ \-/, ' '
      name.gsub! /\ +/, ' '
    end
  end

  # a utility function to remove a series of files.
  def remove_files(*files)
    files.each do |file|
      File.unlink(file) if file and File.exist?(file)
    end
  end
end
