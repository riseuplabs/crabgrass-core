require 'test_helper'

class Mailer::PgpKeyUploadTest < ActionMailer::TestCase

# we want to make sure not to send unencrypted emails if a
# key is invalid or expired

  def setup
    load_users
    mailer_class.deliveries = nil
  end

  def test_forever_key
    mail = mailer_class.key_uploaded_mail(@blue).deliver
    assert_includes mail.body, 'You just uploaded a new key'
    assert mailer_class.deliveries.present?
    assert mailer_class.deliveries.first.encrypted?
  end

  def test_valid_to_2050_key
    mail = mailer_class.key_uploaded_mail(@red).deliver
    assert_includes mail.body, 'You just uploaded a new key'
    assert mailer_class.deliveries.present?
    assert mailer_class.deliveries.first.encrypted?
  end

  # only valid keys can be uploaded, but a key might expire
  def test_expired_key
    mail = mailer_class.key_uploaded_mail(@dolphin).deliver
    assert_includes mail.body, 'You just uploaded a new key'
    assert mailer_class.deliveries.present?
    assert_not mailer_class.deliveries.first.encrypted?
  end

  # would not happen in real life, because it is not possible to
  # upload a broken key
  def test_broken_key
    mail = mailer_class.key_uploaded_mail(@penguin).deliver
    assert_includes mail.body, 'You just uploaded a new key'
    assert mailer_class.deliveries.present?
    assert_not mailer_class.deliveries.first.encrypted?
  end

  protected

  def mailer_class
    Mailer::PgpKeyUploadMailer
  end

  def receive_notifications(type)
    @user.update_attributes receive_notifications: type
  end

  def load_users
    @blue = users(:blue)
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
    @blue.reload

    @red = users(:red)
    expires_2050_key = <<-END
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

mQENBFoZUdoBCAC7JOvwiHwDRlBusvIgILSFRMM2rB71KtJjZ7y4gsWv30QryiOs
PuNzwdR8t8Q26jTgzGAUDzL/VIuQjPm3gm/0ySdMxOVL8TfnG/88CInhyNFOR3QW
ZN5k9wv8oDf3W9k+7A5UPjZ4EIkoS2/8sJyXtwRghsEwjT2rUs9TlhL8U1kCwbTj
apl9HnY6bKjGGpzj45ompCk9GKsJ2/c1keyM0sFzea25lKBQn2mhvEIOZZNVcuQ/
YU9JXkLA46fMgI2rLJe33cs2smwIPgFXIXHj4Hp4PWI3CfN5VZ74C4HhYVH7n6Gm
rtRzUqV8csDxfnTl5BgrgxnbsVHhg2u3tTQ9ABEBAAG0WkNyYWJncmFzcyBSU0Eg
VGVzdCBLZXkgRXhwaXJlcyBpbiAyMDUwIChLZXkgZm9yIHRlc3Rpbmcgb25seSkg
PGNndGVzdC12YWxpZGtleUByaXNldXAubmV0PokBPgQTAQIAKAUCWhlR2gIbAwUJ
PgejgAYLCQgHAwIGFQgCCQoLBBYCAwECHgECF4AACgkQdu7BlCvANwgi2wgAhR3/
lvatoaVh0phTwPio+LzGAojXFPWpzBuv3AwjZ93RYS4P73TVMk5Xdm/uQS0zKFfp
0UNqJ6fL91W8I+x7sqn0k0u1F5GLrLbkLRsQ9Qyd+/J+k7B2vY1SkXGEZ3XSFHhc
8yRbFaiLNWXlpJ/6wG3ArtZSaLoFmNTofFY5RDCBowPQTC0FUq+SEa9d90R02IQb
muGNOensRoqysDA+2n1IiufWZavAuUynPVAPg9eYxw6gOOkzsmkHWSGHCHsLmo0O
8sfG+i1xIc8lHffXpNVP9tqHr/K7cPlu40v3bxKPI5HEy2lrDi5bcbBVFI79vqfR
bO3w5qN/I/mx8MaMg7kBDQRaGVHaAQgA50N5RTR0hHvYs07mVd8rUDFVe4Eze8U1
JMS+rY3ANd9F6FrcxRlClCVI+IPd+bkLSho8bgFazFSKYuB89RClOyGmjdXnEO78
VZ0k/vOWhvAuiH4fGs62J2vbStk4vYQyhY0WrVIa1f4WgiD6Ssp3Zg8xqipCaWxh
kGtGoyb6wx3okPKa0idHMhy6A1p+OoJ92gI3II31AzzupWIseFjlrpHlwiF6tayG
7KLYiqBT1VsAvWJOXqphGewrO4j3F+XrFxXlxcqsPEJ9fkHD9UpcMRRfDNAhbCSU
YmWvzAZgzT7bjYlAtsapyCc+OvmMtYO0SeOpMY7CeGkRVkQzgQrCbwARAQABiQEl
BBgBAgAPBQJaGVHaAhsMBQk+B6OAAAoJEHbuwZQrwDcIh1EIAKPen8apc6fNdeOF
/HHVCjc5ANXB6rAxsjIIjSQuW7nixW/ulj6K+U5UMm8MTwZhnP87oV2OkQ/hwqeN
U9dafvFidIhXPLwpAOXQaR+LCYN9HWzqx+pfdTV9QuSRLOh0UK7/r7dEDTpt2SqY
Sq9Sj6dZWiCrwiZp61MfnRUA7xWvdobg+J32zOXVYhkN9RfYt4kRlPX9fQ5308+8
YMdb2h4or8t6UNDXqehMoDUVAXArVEFAKd/AWg4mYmHJQE1tHhUJ65t04ShLP/nB
JkQHe2rGVWvznPyGsUnSTL33pJ/iDb3hZk5T/eyN/ZOW8medipO05nI2ia7XfEuG
2x+NyPk=
=ZtcX
-----END PGP PUBLIC KEY BLOCK-----
END
    PgpKey.create(user_id: 8, key: expires_2050_key)
    @red.reload

    @dolphin = users(:dolphin)
    expired_key = <<-END
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

mQENBFoZSO8BCADGC9MQbhvvWXoeWLxrx4ZVWc+VR6n/+vlLkaIhz+dE81jUPaP5
BX5WgtesMXMDIXNeSBYvYAoZA9og1nqZ8ZlYPNBH0uZPmfG9zyV9zd8bbO3AC5uX
akFz03rHwxj3gXBAxLWly7ZZFWdI/gDMKI0qypLz5Ml4OhRUaVqwyAVEEtbR87Fm
jZ5FGIYZne8rny0tIIDfAiHIWdKZrm4okNZDkouDHmKG/7HM/32cDTMJreK84/Ic
wnbZmiPQr9ofkl3Sim1+hb+dzgIfpsB35HnN/I3FyEr9IYK+L7ZPznPtI1Z+R28R
GIkWm2i7aJjlvhzEIAs2GHGQkffVkLSCBXsdABEBAAG0VENyYWJncmFzcyBSU0Eg
VGVzdCBLZXkgRXhwaXJlZCAoS2V5IGZvciB0ZXN0aW5nIG9ubHkpIDxjZ3Rlc3Qt
ZXhwaXJlZGtleUByaXNldXAubmV0PokBPgQTAQIAKAUCWhlI7wIbAwUJAAFRgAYL
CQgHAwIGFQgCCQoLBBYCAwECHgECF4AACgkQM/TTxGBRt3A00AgArRlRfbvecT0W
LmkM2QPeOpxoWdw/QGNQn5hno/co9Vpjm9NZDHzdCh3METYyzTzwfNA4uGn9rnPi
IyLSHZS9k0SQIUyfR8Zw17j2iTcFivlQBTHSQxCorPRan625y9v1j5MUjeFNjG8d
iP4uJQIJ0OQwCBk04LJD0LGVL3w5E0jwX0v88jFCrnHbWeyvy2fmsS36WsiQRsei
9PhXBxP7PUcvEC/B/2+HldoId18UvjkhR3Nw4jxuuL6SOviY4pDVmWqVy6usFgDE
q3xR5zbsNXco58AekeBtrbuK7HcvDNCCE7YznMafbmjxdTrXZ716OoPhPOGpXwhp
T2Pve893SLkBDQRaGUjvAQgAtIektUXKq5SizUpVSMSJHeyIR4cxgJhNGuDjTjWG
pQk0drTWt0mbJeR6u4fc6GfxMmq5CHDoPY/2DcbDdVflQrVWn/1l5tCayYLTlMe3
v6VTUo1EnGX4/IchLMKCWHfx5iZ5Uf2zCUKzWqvO3dQo+IfiCItG2DuLPjqBdqOE
FseOn1sDL4EszcTiZTBz4KbXVVPDJ+eTCq+iazmG6ZzOCDUA5mEn8L3q1YsisOJw
FhibEDdjhy6T3aoaSLmU++gebaa3lJHLpcxZavs9Iu91H7KI11NxUqBJoOJN2DgF
Y/NDHkjvBgldJK3m+wO13qzDxZv7prc0LTshIjBEzpHihwARAQABiQElBBgBAgAP
BQJaGUjvAhsMBQkAAVGAAAoJEDP008RgUbdwXMoH/A5mgE7ObVxpfdJ1CqhA7qmJ
tL18G1WbBYPCMxcZUOovGQp1NDrqefvoawAAUU9+9doT09kXWwyeQF4vcmoWwYFz
eXdZbbw8FHx/BWURURaSjGXzRTZePzWrNI2hZ2Ol9QIoNzRVAda8UbuQlFW4Rn0K
eWPqvzqQWt2TvA0H0wz5gyMkqSuQoAq2iLZ6m99oDUv9OGLwRj5beI/MQjG/1RYX
AjevRx1sTLzs5x38Za2xEcDNEdEpKq+ca77m9CCcY6SbxwYxVOID3pD9AxL7S/49
RYPwjboUv9YXBgZBYcmf0GCM0ANytL5w+LkwsplV6bUCrwZ1ekSKPMHT0H8Mp2E=
=fvL3
-----END PGP PUBLIC KEY BLOCK-----
END
    PgpKey.create(user_id: 11, key: expired_key)
    @dolphin.reload

    @penguin = users(:penguin)
    broken_key = "This is definitely not a PGP Key"
    PgpKey.create(user_id: 12, key: broken_key)
    @penguin.reload
  end

end
