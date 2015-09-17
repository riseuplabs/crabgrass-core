#
# For MS Word and documents.
#

class Asset::Text < Asset

  def update_media_flags
    self.is_document = true
  end

  define_thumbnails(
    txt: {ext: 'txt', remote: true},
    odt: {ext: 'odt', remote: true},
    pdf: {ext: 'pdf', remote: true},
    large: {size: '500x500>', ext: 'jpg', depends: :pdf, title: 'Large Thumbnail'},
    medium: {size: '200x200>', ext: 'jpg', depends: :large, title: 'Medium Thumbnail'},
    small: {size: '64x64>',   ext: 'jpg', depends: :large, title: 'Small Thumbnail'}
  )

end

