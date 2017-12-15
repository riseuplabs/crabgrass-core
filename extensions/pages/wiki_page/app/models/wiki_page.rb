class WikiPage < Page
  include Page::RssData

  def title=(value)
    write_attribute(:title, value)
    write_attribute(:name, value.nameize) if value
  end

  # for fulltext index
  def body_terms
    return '' unless data and data.body
    data.body
  end

  def wiki(*args)
    data(*args) or begin
      newwiki = Wiki.new do |w|
        w.user = created_by
        w.body = ''
      end
      self.data = newwiki
      return newwiki if new_record?
      save
      newwiki.reload
    end
  end

  protected

  before_save :update_wiki_group
  def update_wiki_group
    if owner_name_changed?
      wiki.clear_html if wiki
    end
  end
end
