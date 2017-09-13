class Asset::Image < Asset
  def update_media_flags
    self.is_image = true
  end

  define_thumbnails(
    large: { size: '500x500>', ext: 'jpg', title: 'Large Thumbnail' },
    medium: { size: '200x200>', ext: 'jpg', depends: :large, title: 'Medium Thumbnail' },
    small: { size: '64x64>', ext: 'jpg', depends: :large, title: 'Small Thumbnail' }
  )
end
