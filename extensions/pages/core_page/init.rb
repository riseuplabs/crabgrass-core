
define_page_type :DiscussionPage, {
  controller: 'discussion_page',
  icon: 'page_discussion',
  class_group: ['text', 'discussion'],
  order: 2
}

Crabgrass.mod_routes do
  scope path: 'pages' do
    resources :discussions,
      only: [:show, :edit, :update],
      controller: :discussion_page do
        get :print, on: :member
      end
  end
end
