#
# Thumbdef options:
#
# * :size       -- specify in a format accepted by gm.
#                  ie: "64x64>" for resize but keep aspect ratio.
# * :ext        -- the file extension of the thumbnail.
# * :mime_type  -- usually automatic from :ext, but can be manually specified.
# * :depends    -- specifies the name of a thumbnail that must be created first.
#                  if :depends is specified it is used as the source file for this
#                  thumbnail instead of the main asset.
# * :proxy      -- suppose you need other thumbnails to depend on a thumbnail of
#                  of type odt, but the main asset might be an odt... setting
#                  proxy to true will make it so that we use the main asset
#                  file instead of generating a new one (but only if the mime
#                  types match).
# * :title      -- some descriptive text for the kids.
# * :remote     -- if true, try to process this thumbnail remotely, if possible.
# * :binary     -- if true, this data must be treated as binary. if false,
#                  it may be transmitted over text-only channels. default is true.

class Asset::ThumbnailDefinition
  attr_accessor :size, :name, :ext, :mime_type, :depends, :proxy, :title, :remote, :binary
  def initialize(name, hsh)
    self.name = name
    self.binary = true
    hsh.each do |key,value|
      self.send("#{key}=",value)
    end
    self.mime_type ||= Media::MimeType.mime_type_from_extension(self.ext) if self.ext
  end
end
