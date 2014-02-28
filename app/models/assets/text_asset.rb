#
# For MS Word and documents.
#

class TextAsset < Asset

  def update_media_flags
    self.is_document = true
  end

  define_thumbnails(
    :txt    => {:ext => 'txt', :remote => true},
    :odt    => {:ext => 'odt', :remote => true},
    :pdf    => {:ext => 'pdf', :remote => true},
    :small  => {:size => '64x64>',   :ext => 'jpg', :depends => :pdf, :title => 'Small Thumbnail'},
    :medium => {:size => '200x200>', :ext => 'jpg', :depends => :pdf, :title => 'Medium Thumbnail'},
    :large  => {:size => '500x500>', :ext => 'jpg', :depends => :pdf, :title => 'Large Thumbnail'}
  )

end

