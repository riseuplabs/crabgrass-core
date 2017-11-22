class PgpKey < ActiveRecord::Base

  belongs_to :user
  before_validation :update_key
  validates :fingerprint, presence: true, if: :key_present?

  protected

  def update_key
    if self.key_changed?
      create_fresh_gpg_directory
      import_key   
    end
  end

  def create_fresh_gpg_directory
    gpg_dir = Rails.root.join('assets','keyrings', "tmp").to_s
    FileUtils.rm_rf(gpg_dir) if File.exist?(gpg_dir)
   # FileUtils.rm(gpg_dir) if File.exist?(gpg_dir)
    FileUtils.makedirs(gpg_dir)
    ENV['GNUPGHOME']=gpg_dir
  end

  def import_key
    result = GPGME::Key.import self.key
    if result.try.imports.try.first.try.status == 1
      self.fingerprint = result.imports.first.fpr 
      key = GPGME::Key.find(:fingerprint, self.fingerprint).first
      self.expires = key.expires if key
    end
  end

  def key_present?
    key.present?
  end

end
