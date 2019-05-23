require 'test_helper'

class User::SocialTest < ActiveSupport::TestCase
  def setup
    Time.zone = ActiveSupport::TimeZone['Pacific Time (US & Canada)']
  end

  def test_peers
    group = groups(:animals)
    u1 = users(:orange)
    u2 = users(:kangaroo)

    assert !u1.peer_of?(u2),
      'orange and kangaroo should not be peers'
    assert !u2.peer_of?(u1),
      'orange and kangaroo should not be peers'

    group.add_user! u1
    u1.reload; u2.reload

    assert u1.peer_of?(u2),
      'user orange should have gained peer (kangaroo).'
    assert u2.peer_of?(u1),
      'other user (kangaroo) should have gained peer (orange).'

    group.remove_user! u1
    u1.reload; u2.reload

    assert !u1.peer_of?(u2),
      'orange and kangaroo should not be peers'
    assert !u2.peer_of?(u1),
      'orange and kangaroo should not be peers'

    group.add_user! u1
    u1.reload; u2.reload

    assert u1.peer_of?(u2),
      'user (orange) should have gained kangaroo as a peer'
    assert u2.peer_of?(u1),
      'other user (kangaroo) should gained orange as a peer.'

    group.remove_user! u1
    u1.reload; u2.reload

    assert !u1.peer_of?(u2),
      'orange and kangaroo should not be peers'
    assert !u2.peer_of?(u1),
      'orange and kangaroo should not be peers'
  end

  def test_associations
    assert check_associations(User)
  end

  def test_pestering
    green = users(:green)
    kangaroo = users(:kangaroo)
    orange = users(:orange)
    green.revoke_access! public: :pester

    assert kangaroo.stranger_to?(green),
      'must be strangers'
    assert !kangaroo.may?(:pester, green),
      'strangers should be not be able to pester'

    assert orange.peer_of?(green),
      'must be peers'
    assert orange.may?(:pester, green),
      'peers should always be able to pester'

    # users(:green).profiles.public.may_pester = true
    green.grant_access! public: :pester
    assert kangaroo.may?(:pester, green),
      'should be able to pester if set in profile'
  end

end
