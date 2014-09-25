module Integration
  module Navigation

    def click_page_tab(tab)
      find('#page_tabs').click_on(tab)
    end

    def clicking(text)
      while page.has_selector?(:link_or_button, text)
        click_on(text)
        yield
      end
    end
  end
end
