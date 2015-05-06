module CrabgrassDiscussionPage
  class Engine < ::Rails::Engine

    initializer "crabgrass_page.register_discussion_page",
      before: "crabgrass_page.freeze_pages" do |app|
      Crabgrass::Page::ClassRegistrar.add 'DiscussionPage',
        controller: 'discussion_page',
        icon: 'page_discussion',
        class_group: ['text', 'discussion'],
        order: 2
    end

  end
end
