require 'test_helper'

class RecipientsTest < ActiveSupport::TestCase

  def test_email_recipient
    recipient = Recipients.new "test@mail.me"
    assert_equal ["test@mail.me"], recipient.emails
  end

  def test_recipient_from_unchecked_checkbox
    ar = Array({":participants"=>"0"})
    ar.map! do |rec|
      Recipients.new(rec)
    end
    recipient = ar.last
    assert_equal [], recipient.users
    assert_equal [], recipient.groups
    assert_equal [], recipient.emails
    assert_equal [], recipient.specials
    assert_equal Hash.new, recipient.options
  end

end
