class Picture::Storage

  URL_ROOT = PICTURE_PUBLIC_STORAGE.sub(File.join(Rails.root,'public'),'')

  def initialize(picture)
    @picture = picture
  end

  def private_path(geometry=nil)
    File.join(private_directory, file_name(geometry))
  end

  def public_path(geometry=nil)
    File.join(public_directory, file_name(geometry))
  end

  def url(geometry)
    File.join(URL_ROOT, directory, file_name(geometry))
  end

  def dimensions(geometry)
    path = private_path(geometry)
    width, height = Media::GraphicsMagickTransmogrifier.new.dimensions(path)
    [(width||0).to_i, (height||0).to_i]
  end

  def average_color
    Media::GraphicsMagickTransmogrifier.new.average_color(private_path)
  end

  def destroy_files
    FileUtils.rm_rf(private_directory) if File.exist?(private_directory)
    FileUtils.rm(public_directory) if File.exist?(public_directory)
  end

  def destroy_file(geometry)
    FileUtils.rm(public_path(geometry))
    FileUtils.rm(private_path(geometry))
  end

  #
  # Ensures storage directory exists for this Picture
  #
  def allocate_directory
    FileUtils.mkdir_p(private_directory) unless File.exist?(private_directory)
    add_symlink # for now, all Pictures are public.
  end

  #
  # creates a symlink from the private storage to a public storage
  #
  # this makes the picture public
  #
  def add_symlink
    unless File.exist?(public_directory)

      public_directory_parent = File.dirname(public_directory)
      unless File.exist?(public_directory_parent)
        FileUtils.mkdir_p(public_directory_parent)
      end

      real_private_path = Pathname.new(private_directory).realpath
      real_public_path  = Pathname.new(public_directory_parent).realpath
      public_to_private = real_private_path.relative_path_from(real_public_path)
      FileUtils.ln_s(public_to_private, real_public_path)
    end
  end

  #
  # removes symlink that links private and public directories
  #
  # this makes the picture private.
  #
  def remove_symlink
    if File.exist?(public_directory)
      FileUtils.rm(public_directory)
    end
  end

  protected

  #
  # the relative path of the directory where all the files live for
  # this picture. (returned as an array for use in File.join)
  #
  # e.g. id of 12345 produces ['0001','2345']
  #
  def directory
    ("%08d" % @picture.id).scan(/..../)
  end

  #
  # the private filesystem path of this picture
  #
  def private_directory
    File.join(PICTURE_PRIVATE_STORAGE, directory)
  end

  #
  # the public filesystem path of this picture
  #
  def public_directory
    File.join(PICTURE_PUBLIC_STORAGE, directory)
  end

  #
  # returns a file name appropriate for the specified
  # geometry.
  #
  # eg:
  #   {:max_height => 100}  --> '0-0-0-100.jpg'
  #   nil                   --> 'full.jpg'
  #
  #
  def file_name(geometry)
    Picture::Geometry[geometry].to_s + ext
  end


  #
  # returns the file extension suitable for this content_type
  #
  def ext
    Media::MimeType.extension_from_mime_type(@picture.content_type).to_s
  end

end
