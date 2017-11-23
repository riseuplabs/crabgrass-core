require 'test_helper'

class Mailer::PageHistoriesTest < ActionMailer::TestCase

  def setup
    @user = users(:blue)
    add_pgp_key
    watch_page
    mailer_class.deliveries = nil
  end

  def teardown
    Conf.paranoid_emails = false
    super
  end

  def test_wont_encrypt_without_key
    @user = users(:red)
    watch_page
    receive_notifications 'Digest'
    updated_page_as users(:blue)
    mail = mailer_class.deliver_digests.first
    assert_includes mail.body, 'Blue! has modified the page title'
    assert_not mailer_class.deliveries.first.encrypted?
  end

  def test_wont_send_empty_digest
    receive_notifications 'Digest'
    assert_empty mailer_class.deliver_digests.first
    assert_not mailer_class.deliveries.present?
  end

  def test_send_plain_digest
    receive_notifications 'Digest'
    updated_page_as users(:red)
    mail = mailer_class.deliver_digests.first
    assert mailer_class.deliveries.present?
    assert_includes mail.body, 'Red! has modified the page title'
    assert mailer_class.deliveries.first.encrypted?
  end

  def test_send_paranoid_digest
    with_paranoid_emails
    receive_notifications 'Digest'
    updated_page_as users(:red)
    mail = mailer_class.deliver_digests.first
    assert mailer_class.deliveries.present?
    assert_includes mail.body, 'A page that you are watching has been modified'
    assert_not_includes mail.body, 'Red! has modified the page title'
    assert mailer_class.deliveries.first.encrypted?
  end

  def test_wont_send_empty_update
    receive_notifications 'Single'
    updated_page_as users(:red), 1.day.ago
    mail = mailer_class.deliver_updates_for page, to: [@user]
    assert_not mailer_class.deliveries.present?
  end

  def test_send_simple_update
    receive_notifications 'Single'
    updated_page_as users(:green), 5.minutes.ago
    updated_page_as users(:red), 1.minute.ago
    mail = mailer_class.deliver_updates_for(page, to: [@user]).first
    assert mailer_class.deliveries.present?
    assert_includes mail.body, 'Red! has modified the page title'
    assert_includes mail.body, 'Green! has modified the page title'
    assert mailer_class.deliveries.first.encrypted?
  end

  def test_send_simple_update_comment_and_wiki
    receive_notifications 'Single'
    added_comment_as users(:red), 1.minute.ago
    updated_wiki_as users(:red), 1.minute.ago
    mail = mailer_class.deliver_updates_for(page, to: [@user]).first
    assert mailer_class.deliveries.present?
    assert_includes mail.body, 'Red! added a comment'
    assert_includes mail.body, 'Red! has updated the page content'
    assert mailer_class.deliveries.first.encrypted?
  end

  def test_send_paranoid_update
    with_paranoid_emails
    receive_notifications 'Single'
    updated_page_as users(:red), 1.minute.ago
    mail = mailer_class.deliver_updates_for(page, to: [@user]).first
    assert mailer_class.deliveries.present?
    assert_not_includes mail.body, 'Red! has modified the page title'
    assert_includes mail.body, 'A page that you are watching has been modified'
    assert mailer_class.deliveries.first.encrypted?
  end

  protected

  def add_pgp_key
    valid_forever_key = <<-END
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1
 
mQENBFoZRyUBCAC3bZRE1tqVFw+nt2mGjdGfWWgZxwfEtSns0Vdcgg3eisspbuEb
4daG6qWJ4sq9Mt+AK2RLiRFMvPO+Dz5MjCHid1RyVu+ztta60sMDwA4vZB5FCVgQ
RnzSvDhJ9qSkl7W9pdsO9cStycj87yh/+Us+Dgt90LWpU0uGLE+l51TgqIWxWUPk
vbG+p/IrnXDgvBRhBBuwT9muZ1sQu/jLpHqSccf4Ai6Donj2BasjTtVbX0ST0ebc
xpgE++iZ0gPxJ9rqJtf9E+eYXFAVTKmO6onBAAe5TkXchcMjkJZ1ZzKDY+GgCFz6
FMzbsf8vVqsINGMqezLDJ9JSLFRtq3Jp7HpNABEBAAG0WkNyYWJncmFzcyBSU0Eg
VGVzdCBLZXkgTmV2ZXIgRXhwaXJlcyAoS2V5IGZvciB0ZXN0aW5nIG9ubHkpIDxj
Z3Rlc3QtZm9yZXZlcmtleUByaXNldXAubmV0PokBOAQTAQIAIgUCWhlHJQIbAwYL
CQgHAwIGFQgCCQoLBBYCAwECHgECF4AACgkQfwtpdIzz1QMlkwgAoIY++VLnp2LJ
VB0l1GiHMKbue4riUx646ApGFvkRT4wPleKexrJdbGJjUGogScNE6xrq0sRsvuc/
1HO+Dg6gpGnxbjdWCxyAItietoKP20ya9Aw8DmgANxVtaqyS9VK5ZNCguWzIsxFW
5tivcaFk6lQQKnyKUBsybaLrk/ylcvDOQEhvYjG+sPp5WfzRgLCtQ820SrjxRkAd
t8uf7hYvEOkH4i9vx29XAgleYhXwx5U/KXEhquJ3FUd7/29F3kKgMVegm8lUT65G
hpBMIpZ8O1ZLECCoPJKqdue9o+XqGxaDU8a88jM/Fj5ZYqv/O7fXMw0GLB76Z1P3
f6QzmV/MSLkBDQRaGUclAQgA3cqu6VL+QBE4cV3OFdTeeaWecOs6wvnWPjTr0/VE
BWsqWAusNQU0o5NKKVX58Au0Lbm6By9ooSzLhiUtQoXJ0BMmIoypKJTof53hgqkU
PxbnqQiHrre/DUbT1EIPsHAKLi7R9iyUVMIykFYt8eOaW6NR3jzxkZH2YAShUEsu
AjlZ3yEXVOaQmO6fZlKUsqsmzkiU/qBSZEnvdT8jqweWFXB4GMYMIELWVBrrra1S
XU32vFgr7JNHashBCP+uxdmfw/REPzWnj4mZUvgiFsdS6o5/2elieve+1T+R0aci
Wdwn7xY8LOUvNteeVoFMwkg9ohX/ecq3qW2vKv1CCK7aQQARAQABiQEfBBgBAgAJ
BQJaGUclAhsMAAoJEH8LaXSM89UDeTgH/0n5VYfivPnCJpYr/nhC/8iOHzUQG4Po
4GlGe0mZ5KrCUcp24Dsoip84KWcuIyiacfbZQ5V5lxJgCWqstCrexuFq3o+hXj5/
oCL4cvVQS5Y9qp03PbASCrNWSX8rX8yIVDH7t7cmixglsqy3Qxq36yYFz4v8M5hw
jWM0JXPo1jwD/Mubfr7wjMu0gl655TI+Jt/5u78WZX4YCbva0epV/H9Lo3pvntny
iBvVLeZkIbKUbTNoS7Xv044xUubzEqqQIRl6Cui4yx6BYiuvAzCzllgh6aLrn5mv
UNbV3a5WNYy1Uyz7PPZcxY3b/JtKsYr9YfAzRQSQ0xA5xq2QdzQsdq8=
=oHuj
-----END PGP PUBLIC KEY BLOCK-----
END
    PgpKey.create(user_id: 4, key: valid_forever_key)
    @user.reload
  end

  def with_paranoid_emails
    Conf.paranoid_emails = true
  end

  def mailer_class
    Mailer::PageHistories
  end

  def watch_page
    page.user_participations.where(user_id: @user).create watch: true
  end

  def receive_notifications(type)
    @user.update_attributes receive_notifications: type
  end

  def updated_page_as(user, time = 1.day.ago)
    page.title = 'new title from ' + user.display_name
    page.updated_by user
    page.save
    Page::History::ChangeTitle.create user: user, page: page, created_at: time
  end

  def added_comment_as(user, time = 1.day.ago)
    post = FactoryBot.create(:post) 
    page.add_post(user, body: post)
    page.updated_by user
    page.save
    assert page.discussion.present?
    Page::History::AddComment.create user: user, page: page, created_at: time, item: post
  end 
  
  def updated_wiki_as(user, time = 1.day.ago)
    page.updated_by user
    page.save
    assert page.discussion.present?
    Page::History::UpdatedContent.create user: user, page: page, created_at: time
  end 


  def page
    @page ||= pages(:blue_page)
  end
end
