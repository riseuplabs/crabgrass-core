module Integration
  module Navigation

    def select_page_tab(tab)
      return if find('#page_tabs li.tab.active').has_content?(tab)
      click_page_tab(tab)
      assert_page_tab(tab)
    end

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
