require 'integration_test'

class PgpKeyUploadTest < IntegrationTest
  def setup
    super
    login
    mailer_class.deliveries = nil

    @valid_forever_key = <<-END
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

  @expired_key = <<-END
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

end
  # FIXME: workaround - not sure if it really makes sense to
  #        rename the form field to 'context'
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
    fill_in 'user_pgp_key_attributes_key', with: "This is definitely not a PGP Key"
    click_on 'Save'
    assert_no_content 'Fingerprint'
    assert_content "The key you entered cannot be imported"
    assert_not mailer_class.deliveries.present?
  end

  def test_upload_expired_key
    click_on 'Settings'
    fill_in 'user_pgp_key_attributes_key', with: @expired_key
    click_on 'Save'
    assert_no_content 'Fingerprint'
    assert_content "The PGP key you entered is expired"
    assert_not mailer_class.deliveries.present?
  end

  def test_upload_valid_forever_key
    click_on 'Settings'
    fill_in 'user_pgp_key_attributes_key', with: @valid_forever_key
    click_on 'Save'
    assert_content 'Fingerprint'
    assert mailer_class.deliveries.present?
    assert mailer_class.deliveries.first.encrypted?
  end

  def test_upload_same_key_twice
    click_on 'Settings'
    fill_in 'user_pgp_key_attributes_key', with: @valid_forever_key
    click_on 'Save'
    assert_content 'Fingerprint'
    mailer_class.deliveries = nil
    click_on 'Settings'
    fill_in 'user_pgp_key_attributes_key', with: @valid_forever_key
    click_on 'Save'
    assert_content 'Fingerprint'
    assert_not mailer_class.deliveries.present?
  end

  def test_replace_valid_key_with_empty_key
    click_on 'Settings'
    fill_in 'user_pgp_key_attributes_key', with: @valid_forever_key
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
    fill_in 'user_pgp_key_attributes_key', with: @valid_forever_key
    click_on 'Save'
    assert_content 'Fingerprint'
    mailer_class.deliveries = nil
    click_on 'Settings'
    fill_in 'user_pgp_key_attributes_key', with: @expired_key
    click_on 'Save'
    assert_no_content 'Fingerprint'
    assert_not mailer_class.deliveries.present?
  end

  def mailer_class
    Mailer::PgpKeyUploadMailer
  end

end
