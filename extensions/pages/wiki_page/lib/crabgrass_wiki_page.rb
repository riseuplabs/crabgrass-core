require 'crabgrass/page/engine'

module CrabgrassWikiPage
  class Engine < ::Rails::Engine
    include Crabgrass::Page::Engine

    register_page_type :WikiPage,
      controller: 'wiki_page',
      icon: 'page_text',
      class_display_name: 'wiki',
      class_description: :wiki_class_description,
      class_group: 'text',
      order: 1

    register_page_type :ArticlePage,
      controller: 'article_page',
      icon: 'page_article',
      class_display_name: 'article',
      class_description: :article_class_description,
      class_group: 'text',
      order: 4

  end
end


