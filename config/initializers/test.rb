#
# testing specific initializer.
#

if Rails.env.test?

  # https://github.com/stympy/faker/issues/10
  Faker::Config.locale = 'en-US'

end
