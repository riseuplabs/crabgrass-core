unless defined?(Media::TMP_PATH)
  if defined?(Rails)
    Media::TMP_PATH = File.join(Rails.root, 'tmp', 'media')
  else
    Media::TMP_PATH = File.join('', 'tmp', 'media')
  end
end

FileUtils.mkdir_p(Media::TempFile.tempfile_path) unless File.exist?(Media::TempFile.tempfile_path)
