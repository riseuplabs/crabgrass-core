module Integration
  module Possibility
    def open_new_possibility_form
      unless page.has_button? 'Add new Possibility'
        click_link 'Add new Possibility'
      end
    end

    def close_new_possibility_form
      if page.has_button? 'Add new Possibility'
        click_link 'Add new Possibility'
      end
    end

    def add_possibility(description = nil, detail = nil)
      open_new_possibility_form
      description ||= Faker::Lorem.sentence
      detail ||= Faker::Lorem.paragraph
      fill_in 'poll_possible_name', with: description
      fill_in 'poll_possible_description', with: detail
      click_button 'Add new Possibility'
      assert_text description
      close_new_possibility_form
      [description, detail]
    end
  end
end
