require_relative 'navigation'

module Integration
  module Comments
    include Integration::Navigation

    def post_comment(text = nil)
      text ||= Faker::Lorem.paragraph
      fill_in :post_body, with: text
      click_on "Post Message"
      text
    end

    def edit_comment(comment, new_text)
      hover_and_edit(comment) do
        fill_in :post_body, with: new_text
        click_on 'Save'
      end
      new_text
    end
  end
end
