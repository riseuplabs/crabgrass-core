require 'machinist/active_record'
require 'sham'
require 'faker'

#
# Common
#

def created_date(average_days = 30)
  (average_days + 5 + rand(5)).days.ago.to_s(:db)
end

def updated_date(average_days = 30)
  (average_days + rand(5)).days.ago.to_s(:db)
end

def boolean
  rand(2) == 1 ? true : false
end

Sham.title            { Faker::Lorem.words(3).join(" ").capitalize }
Sham.email            { Faker::Internet.email }
Sham.login            { Faker::Internet.user_name.gsub(/[^a-z]/, "") }
Sham.display_name     { Faker::Name.name }
Sham.summary          { Faker::Lorem.paragraph }
Sham.caption          { Faker::Lorem.words(5).join(" ") }

#
# Site
#
Site.blueprint do
  # make sites available from functional tests
  domain       "localhost"
  email_sender "robot@$current_host"
end

#
# Users
#
User.blueprint do
  login
  display_name
  email
  salt              { Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") }
  crypted_password  { Digest::SHA1.hexdigest("--#{salt}--#{login}--") }

  created_at        { created_date }
  last_seen_at      { updated_date }
end

