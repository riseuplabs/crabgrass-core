module Wikis::BaseHelper

  protected

  # this will eventually go away once we move the group/wiki and page/wiki
  # controllers over

#form_for(@wiki) calls this because
#form_for([@base, @wiki]) do |f|
# does something like  wiki_path(@wiki, page_id => @base.id)
# for page wikis, we will instead use a version of this defined in
# extensions/pages/wiki_page/app/helpers/wiki_page_helper.rb
  def wiki_path(wiki = @wiki)
    url_for [wiki.context, wiki] #will not work for page
  end

end
