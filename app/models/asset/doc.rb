# A generic document asset: anything that we can create a pdf out of.
#
# See Asset::Spreadsheet for more specific asset types.
#
# What files become doc assets? This is set by lib/media/mime_type.rb
# What doc files may generate thumbnails? This is set by lib/media/processors.rb
#

class Asset::Doc < Asset
  def update_media_flags
    self.is_document = true
  end

  define_thumbnails(
    pdf: { ext: 'pdf', remote: true },
    large: { size: '500x500>', ext: 'jpg', depends: :pdf, title: 'Large Thumbnail' },
    medium: { size: '200x200>', ext: 'jpg', depends: :large, title: 'Medium Thumbnail' },
    small: { size: '64x64>', ext: 'jpg', depends: :large, title: 'Small Thumbnail' }
  )
end
