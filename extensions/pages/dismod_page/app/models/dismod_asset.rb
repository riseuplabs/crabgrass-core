class DismodAsset < Asset

  define_thumbnails(
    :output => {:ext => 'json', :mime_type => 'application/dismod-output', :title => 'Dismod Output'}
#   :preview => {:ext => 'jpg', :title => 'Preview'}
  )

end

