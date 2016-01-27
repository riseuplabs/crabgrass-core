class Asset::Version
  delegate :page, :public?, :has_access!, to: :asset

  # all our paths will have version info inserted into them
  def path
    @path ||= Asset::Storage::Path.new id: asset.id,
      filename: filename,
      version: version.to_s
  end

  # this object is a version, not the main asset
  def is_version?; true; end

  # delegate call to thumbdefs to our original Asset subclass.
  # eg: Asset::Version#thumbdefs --> Asset::Image.thumbdefs
  def thumbdefs
    "Asset::#{versioned_type}".constantize.class_thumbdefs if versioned_type
  end

  def type_as_parent
    'Asset::Version'
  end

  # for this version, hard link the files from the main asset
  after_create :clone_files_from_asset, :clone_thumbnails_from_asset
  def clone_files_from_asset
    clone_files_from(asset); true
  end
  def clone_thumbnails_from_asset
    clone_thumbnails_from(asset); true
  end
end
