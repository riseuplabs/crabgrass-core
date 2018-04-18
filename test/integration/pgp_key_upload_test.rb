require 'integration_test'

class PgpKeyUploadTest < IntegrationTest
  def setup
    super
    login
    mailer_class.deliveries = nil
  end

  def test_upload_empty_key
    click_on 'Settings'
    fill_in 'user_pgp_key_attributes_key', with: "\n   \t"
    click_on 'Save'
    assert_no_content 'Fingerprint'
    assert_content "Changes saved"
    assert_not mailer_class.deliveries.present?
  end

  def test_upload_broken_key
    click_on 'Settings'
    fill_in 'user_pgp_key_attributes_key', with: pgp_keys(:red_broken).key
    click_on 'Save'
    assert_no_content 'Fingerprint'
    assert_content "The key you entered cannot be imported"
    assert_not mailer_class.deliveries.present?
  end

  def test_upload_expired_key
    click_on 'Settings'
    fill_in 'user_pgp_key_attributes_key', with: pgp_keys(:green_expired).key
    click_on 'Save'
    assert_no_content 'Fingerprint'
    assert_content "The PGP key you entered is expired"
    assert_not mailer_class.deliveries.present?
  end

  def test_upload_valid_forever_key
    click_on 'Settings'
    fill_in 'user_pgp_key_attributes_key', with: pgp_keys(:blue_valid_forever).key
    click_on 'Save'
    assert_content 'Fingerprint'
    assert mailer_class.deliveries.present?
    assert mailer_class.deliveries.first.encrypted?
  end

  def test_upload_same_key_twice
    click_on 'Settings'
    fill_in 'user_pgp_key_attributes_key', with: pgp_keys(:blue_valid_forever).key
    click_on 'Save'
    assert_content 'Fingerprint'
    mailer_class.deliveries = nil
    click_on 'Settings'
    fill_in 'user_pgp_key_attributes_key', with: pgp_keys(:blue_valid_forever).key
    click_on 'Save'
    assert_content 'Fingerprint'
    assert_not mailer_class.deliveries.present?
  end

  def test_replace_valid_key_with_empty_key
    click_on 'Settings'
    fill_in 'user_pgp_key_attributes_key', with: pgp_keys(:blue_valid_forever).key
    click_on 'Save'
    assert_content 'Fingerprint'
    mailer_class.deliveries = nil
    click_on 'Settings'
    fill_in 'user_pgp_key_attributes_key', with: "\n   \t"
    click_on 'Save'
    assert_no_content 'Fingerprint'
    assert_not mailer_class.deliveries.present?
  end

  def test_replace_valid_key_with_invalid_key
    click_on 'Settings'
    fill_in 'user_pgp_key_attributes_key', with: pgp_keys(:blue_valid_forever).key
    click_on 'Save'
    assert_content 'Fingerprint'
    mailer_class.deliveries = nil
    click_on 'Settings'
    fill_in 'user_pgp_key_attributes_key', with: pgp_keys(:green_expired).key
    click_on 'Save'
    assert_no_content 'Fingerprint'
    assert_not mailer_class.deliveries.present?
  end

  def mailer_class
    Mailer::PgpKeyUploadMailer
  end

end
