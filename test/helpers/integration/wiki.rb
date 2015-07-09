module Integration
  module Wiki
    # prepare the data without browser interaction
    def create_wiki_version(user, content = nil)
      content ||= Faker::Lorem.paragraphs(4).join("\n")
      next_version = @wiki.versions.last.try.version.to_i + 1
      @wiki.update_section! :document, user, next_version, content
    end

    # update wiki in the browser
    def update_wiki(content = nil)
      # work around not being on edit to begin with
      select_page_tab 'Edit'
      content ||= Faker::Lorem.paragraphs(4).join("\n")
      within('form.edit_wiki') do
        fill_in 'wiki[body]', with: content
        click_on 'Save'
      end
      content
    end
  end
end
