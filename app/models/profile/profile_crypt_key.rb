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

  def create_fresh_gpg_directory
    gpg_dir = "assets/keyrings/tmp"
    FileUtils.rm_rf(gpg_dir) if File.exist?(gpg_dir)
    FileUtils.rm(gpg_dir) if File.exist?(gpg_dir)
    Dir.mkdir(gpg_dir)
    ENV['GNUPGHOME']=gpg_dir
  end

end
