module Integration
  module Navigation
    def select_page_tab(tab)
      return if find('#title_box .nav-tabs li.active').has_content?(tab)
      click_page_tab(tab)
      assert_page_tab(tab)
    end

    def click_page_tab(tab)
      find('#title_box .nav-tabs').click_on(tab)
    end

    def clicking(text)
      while page.has_selector?(:link_or_button, text)
        click_on(text)
        yield
      end
    end

    def hover_and_edit(text)
      target = page.find('.shy_parent', text: text)
      target.hover
      within '.shy_parent:hover' do
        find('a.shy', text: 'Edit').click
        yield if block_given?
      end
    end
  end
end
