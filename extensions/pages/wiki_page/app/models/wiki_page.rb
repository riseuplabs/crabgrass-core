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

  protected

  def wiki_with_auto_create(*args)
    wiki_without_auto_create(*args) or begin
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

  alias wiki data
  alias_method_chain :wiki, :auto_create

  before_save :update_wiki_group
  def update_wiki_group
    if owner_name_changed?
      wiki.clear_html if wiki
    end
  end
end
