module Integration
  module Wiki
    def update_wiki(content = nil)
      # work around not being on edit to begin with
      click_page_tab 'Edit'
      # ensure the edit page is loaded
      find('li.active a.active', text: 'Edit')
      content ||= Faker::Lorem.paragraphs(4).join("\n")
      within('form.edit_wiki') do
        fill_in 'wiki[body]', with: content
        click_on 'Save'
      end
      content
    end
  end
end
