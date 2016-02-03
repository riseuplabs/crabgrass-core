require_relative 'test_helper'

class ProfileTest < ActiveSupport::TestCase



  def setup
    Time.zone = ActiveSupport::TimeZone["Pacific Time (US & Canada)"]
    Media::Transmogrifier.verbose = false  # set to true to see all the commands being run.
    FileUtils.mkdir_p(ASSET_PRIVATE_STORAGE)
    FileUtils.mkdir_p(ASSET_PUBLIC_STORAGE)
  end

  def test_adding_profile
    u = users(:blue)
    p = u.profiles.create stranger: true, first_name: 'Blue'

    assert p.valid?, 'profile should be created'
    assert_equal u.id, p.entity_id, 'profile should belong to blue'

    p.save_from_params(
      last_name: 'McBlue',
      phone_numbers: {
        1 => {phone_number_type: 'Home', phone_number: '(206) 555-1111'},
        2 => {phone_number_type: 'Cell', phone_number: '(206) 555-2222'}
      }
    )
    assert_equal '(206) 555-1111', p.phone_numbers.first.phone_number, 'save_from_params should update phone_numbers'

  end

  def test_public_private
    user = users(:green)
    assert_not_equal nil, user.profiles.public.id, 'should have a public profile'
    assert_not_equal nil, user.profiles.private.id, 'should have a private profile'
  end

  def test_permissions
    blue = users(:blue)
    red = users(:red)

    red.add_contact!(blue, :friend)

    blue.profiles.private.update_attribute(:organization, 'rainbows')
    blue.profiles.public.update_attribute(:organization, 'none')

    profile = blue.profiles.visible_by(red)
    assert profile, 'red should be able to view blue profile'
    assert_equal "rainbows", profile.organization, "should show organization 'rainbows' in profile"

    profile = blue.profiles.visible_by(nil)
    assert profile, 'there should be a public profile'
    assert_equal "none", profile.organization, "should show organization 'none' in profile"
  end

  def test_single_table_inheritance
    user = users(:kangaroo)
    p = user.profiles.create stranger: true
    assert_equal 'User', p.entity_type, 'polymorphic association should work even with single table inheritance'
  end

  def test_wiki
    g = Group.create name: 'trees'
    assert g.profiles.public, 'there should be a public profile'
    w = g.profiles.public.create_wiki
    assert_equal w.profile, g.profiles.public, 'wiki should have a profile'
  end

  def test_find_by_access
    g = Group.create name: 'berries'
    p1 = g.profiles.create(
      stranger: true
    )
    p2 = g.profiles.find_by_access(:stranger)
    p3 = g.profiles.public

    assert_equal p1.id, p2.id, 'find_by_access should have returned the profile we just created'
    assert_equal p1.id, p3.id, 'profiles.public should return the profile we just created'
  end

  def test_assets
    user = users(:blue)
    profile = user.profiles.create stranger: true, first_name: user.name

    assert_difference 'Picture.count' do
      profile.save_from_params('picture' => {
        'upload' => upload_data('image.png'), 'caption' => 'pigeon point'
      })
    end

    assert_not_nil profile.picture(true).public_file_path
    assert_equal 'pigeon point', profile.picture.caption

    if defined?(ExternalVideo)
      assert_difference 'ExternalVideo.count' do
        profile.save_from_params(video: {
          media_embed: external_videos(:beauty_is_in_the_street_video).media_embed
        })
      end
    else
      skip 'ExternalVideo not defined'
    end

    assert_difference 'Picture.count', -1 do
      profile.destroy
    end
  end

  def test_associations
    assert check_associations(Profile)
  end

end

