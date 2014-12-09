module Integration
  module Possibility

    def add_possibility(description = nil, detail = nil)
      description ||= Faker::Lorem.sentence
      detail ||= Faker::Lorem.paragraph
      fill_in 'possible_name', with: description
      fill_in 'possible_description', with: detail
      click_button "Add new possibility"
      assert_text description
      return description, detail
    end
  end
end
