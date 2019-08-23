class AssetPage < Page
  include Page::RssData

  before_save :set_cover

  def supports_attachments
    false
  end

  def icon
    return asset.small_icon if asset
    'page_package'
  end

  after_save :update_access
  def update_access
    asset.update_access if asset && saved_change_to_public?
  end

  def asset
    data
  end

  def asset=(a)
    self.data = a
  end

  # title is the filename if title hasn't been set
  def title
    self['title'] || (data.filename.nameize if data && data.filename)
  end

  # Return string of Asset text, for the full text search index
  def body_terms
    return '' unless asset and asset.thumbnail(:txt)

    thumbnail = asset.thumbnail(:txt)
    thumbnail.generate unless File.exist?(thumbnail.private_filename)
    begin
      File.open(thumbnail.private_filename, encoding: 'iso-8859-1').read
    rescue
      ''
    end
  end

  # called by Page#update_page_terms
  def custom_page_terms(terms)
    asset = data
    if asset
      if asset.new_record?
        asset.page_terms = terms
      elsif asset.page_terms_id != terms.id
        asset.page_terms_id = terms.id
        asset.save_without_revision!
      end
    end
  end

  def set_cover
    self.cover = data if data.is_a?(Asset::Image)
  end
end
