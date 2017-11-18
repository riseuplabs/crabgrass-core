class ProfileCryptKey < ActiveRecord::Base

  self.table_name = 'crypt_keys'

  belongs_to :profile, class_name: 'Profile', foreign_key: 'profile_id'
  before_save :set_fingerprint
  after_save { |record| record.profile.save if record.profile }
  after_destroy { |record| record.profile.save if record.profile }

  protected

  def set_fingerprint
    if key_changed?
      create_fresh_gpg_directory
      res = GPGME::Key.import self.key
      self.fingerprint = res.imports.first.fpr if res.try.imports.try.first.status == 1
      key = GPGME::Key.find(:fingerprint, self.fingerprint).first
      # key.usable_for?([:encrypt])
      # key.expired
      # key.expires # 2018-04-12 17:00:00 +0200
    else
      fingerprint
    end
  end

  # TODO: not sure if we really should create a new keyring each time a user uploads a key
  # This has the advantage, that the keyring will not contain old and unused keys
  def create_fresh_gpg_directory
    gpg_dir = Rails.root.join('assets','keyrings', "tmp").to_s
    FileUtils.rm_rf(gpg_dir) if File.exist?(gpg_dir)
   # FileUtils.rm(gpg_dir) if File.exist?(gpg_dir)
    FileUtils.makedirs(gpg_dir)
    ENV['GNUPGHOME']=gpg_dir
  end

end
