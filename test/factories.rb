require 'faker'

FactoryGirl.define do
  sequence(:created_date) { |n| (n + 5 + rand(5)).days.ago.to_s(:db) }
  sequence(:updated_date) { |n| (n + 5 + rand(5)).days.ago.to_s(:db) }
  sequence(:boolean)      { |n| rand(2) == 1 ? true : false }
  sequence(:title)        { |n| Faker::Lorem.words(3).join(" ").capitalize }
  sequence(:email)        { |n| Faker::Internet.email }
  sequence(:login)        { |n|
    uname = Faker::Internet.user_name.gsub(/[^a-z]/, "")
    uname += Faker::Lorem.characters(4 - uname.size) if uname.size < 3
    uname
  }
  sequence(:display_name) { |n| Faker::Name.name }
  sequence(:summary)      { |n| Faker::Lorem.paragraph }
  sequence(:caption)      { |n| Faker::Lorem.sentence }

  factory :site do
    domain       "localhost"
    email_sender "robot@$current_host"
  end

  factory :user do
    login
    display_name
    email
    password "foobar"
    password_confirmation "foobar"
  end

  factory :group do
    full_name { generate(:display_name) }
    name      { full_name.gsub(/[^a-z]/,"") }

    factory(:committee, :class => Committee) {}
    factory(:council, :class => Council) {}
    factory(:network,   :class => Network)   {}
  end

  factory(:membership) {}

  factory :page do
    title
    summary
    stars_count 0
    created_at  { generate(:created_date) }
    updated_at  { generate(:updated_date) }
    views_count { rand(100) }
    resolved    { generate(:boolean) }

    factory(:wiki_page, class: WikiPage)             {}
    factory(:discussion_page, class: DiscussionPage) {}
    factory(:gallery, class: Gallery)                {}
    factory(:showing, class: Showing)                {}
    factory(:asset_page, class: AssetPage)           {}
  end

  factory :asset do
    created_at    { generate(:created_date) }
    updated_at    { generate(:updated_date) }
    caption
    version       1
    association :parent_page, factory: :asset_page

    factory :image_asset do
      content_type  "image/jpeg"
      height        500
      width         333
      filename      "bee.jpg"
      size          100266
      is_image      true
    end
  end

  factory :user_participation do
    access 1
    watch false
  end

  factory :group_participation do
    access 1
  end

  factory :wiki do
    version 1
    sequence(:body) { |n| Faker::Lorem.paragraphs(10).join "\n" }
  end

  factory(:rate_many_page) {}
  factory(:poll)           {}
  factory(:ranking_poll)   {}
  factory(:rating_poll)    {}

  factory(:discussion) {}

  factory :post do
    discussion
    sequence(:body) { |n| Faker::Lorem.paragraph }
    user
  end

  if Conf.mod_enabled? 'moderation'
    factory :moderation do
      reason_flagged     "language"
      sequence(:comment) { |n| Faker::Lorem.paragraph }
      created_at         { generate(:updated_date) } # this should be newer than the page
      type               { "ModeratedFlag" }
      user
    end
  end

  factory :profile do
    factory :public_profile do
      stranger true
    end

    factory :private_profile do
      friend true
    end
  end

  factory(:geo_country)    {}
  factory(:geo_admin_code) {}
  factory(:geo_location)   {}
  factory :geo_place do
    latitude  1.0
    longitude 1.0
    geonameid 2
  end
end
