class AudioAsset < Asset

  def update_media_flags
    self.is_audio = true
  end

  # no audio preview currently
  def embedding_partial
    false
  end

  define_thumbnails(
    ogg: {ext: 'ogg', title: 'Ogg Audio', proxy: true},
    mp3: {ext: 'mp3', title: 'MP3 Audio', proxy: true}
  )

end

