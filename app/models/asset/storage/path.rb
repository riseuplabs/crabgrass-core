#
# Asset::Storage::Path
#
# Handle the locations for the different asset files:
#
# (1) We want to keep two sets of file storage paths: one for private files and
#     one for public files. When an asset becomes public, we create a symbolic
#     link in the public directory to the file in the private directory.
#
# (2) Assets may be versioned. We keep the versions in a subfolder called 'versions'
#
# Lets suppose you have an asset called 'myfile.jpg' and have defined two thumbnails,
# one called :minithumb and one called :bigthumb.
#
# This is what the directory structure will look like:
#
#   Rails.root/
#     assets/
#       0000/
#         0055/
#          myfile.jpg
#          myfile_minithumb.jpg
#          myfile_bigthumb.jpg
#          versions/
#            1/
#              myfile.jpg
#              myfile_minithumb.jpg
#              myfile_bigthumb.jpg
#   public/
#     assets/
#       55 --> ../../assets/0000/0055/

require 'pathname'

class Asset::Storage::Path
  @@private_storage = ASSET_PRIVATE_STORAGE # \ set in environments/*.rb
  @@public_storage  = ASSET_PUBLIC_STORAGE  # /
  @@public_url_path = "/assets"
  mattr_reader :public_url_path

  def self.private_storage
    Pathname.new(@@private_storage)
  end

  def self.public_storage
    Pathname.new(@@public_storage)
  end

  attr_reader :id, :filename

  def initialize(args)
    @id = args[:id].to_i
    @filename = args[:filename]
    @version = args[:version]
  end

  def version_path
    @version ? [:versions, @version] : []
  end

  # eg Rails.root/assets/0000/0055/myfile.jpg
  # or Rails.root/assets/0000/0055/versions/1/myfile.jpg
  # or Rails.root/assets/0000/0055/versions/1/myfile~small.jpg
  def private_filename(name = filename)
    path @@private_storage, partitioned_path, version_path, name
  end

  # eg Rails.root/public/assets/55/myfile.jpg
  # or Rails.root/public/assets/55/versions/1/myfile.jpg
  # or Rails.root/public/assets/55/versions/1/myfile~small.jpg
  def public_filename(name = filename)
    path @@public_storage, id, version_path, name
  end

  # eg /assets/55/myfile.jpg
  # or /assets/55/versions/1/myfile.jpg
  # or /assets/55/versions/1/myfile~small.jpg
  def url(name = filename)
    path public_url_path, id, version_path, CGI.escape(name)
  end

  protected

  # with a id of 4, returns ['0000','0004']
  def partitioned_path
    ("%08d" % id).scan(/..../)
  end

  # TODO: do we still need this?
  # make a file or url path out of potentially missing or nested args
  def path(*args)
    args.flatten.compact.join('/')
  end

end
