define_page_type :WikiPage, {
  controller: 'wiki_page',
  icon: 'page_text',
  class_display_name: 'wiki',
  class_description: :wiki_class_description,
  class_group: 'text',
  order: 1
}

define_page_type :ArticlePage, {
  controller: 'article_page',
  icon: 'page_article',
  class_display_name: 'article',
  class_description: :article_class_description,
  class_group: 'text',
  order: 4
}


Crabgrass.mod_routes do
  scope path: 'pages' do
    resources :wikis, controller: :wiki_page, only: :show do
# TODO: bring back print view
#        get :print, on: :member
      end
  end
end

