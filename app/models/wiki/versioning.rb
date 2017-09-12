module Wiki::Versioning
  class VersionNotFoundError < CrabgrassException
    def initialize(version_or_message = '', options = {})
      message = version_or_message.is_a?(Integer) ?
        :version_doesnt_exist.t(version: version_or_message.to_s) :
        version_or_message.to_s
      super(message, options)
    end
  end

  class VersionExistsError < CrabgrassException
    def initialize(version_or_message = '', options = {})
      message = version_or_message.respond_to?(:user) ?
        :version_exists_error.t(user: version_or_message.user.display_name) :
        version_or_message.to_s
      super(message, options)
    end
  end

  def create_new_version?
    # always create a new version if we have no versions at all
    return true if versions.empty?
    # overwrite blank versions (we don't want to store blank versions)
    return false if current.body.blank?
    body_changed? && (user_id_changed? || long_time_no_updates?)
  end

  def long_time_no_updates?
    updated_at && (updated_at < 30.minutes.ago)
  end

  def current
    versions.order(:version).last
  end

  def former
    last_version_before(last_seen_at) if last_seen_at.present?
  end

  # returns first version since +time+
  def last_version_before(time)
    return nil unless time
    versions.where('updated_at <= :time', time: time)
            .order('updated_at DESC').first
  end

  def find_version(number)
    versions.find_by_version(number) or
      raise VersionNotFoundError.new(number.to_i)
  end

  # reverts and keeps all the old versions
  def revert_to_version(version, user)
    self.body = version.body
    self.user = user
    save!
  end

  # reverts and deletes all versions after the reverted version.
  def revert_to_version!(version_number, _user = nil)
    revert_to(version_number)
    destroy_versions_after(version_number)
  end

  # update the latest Wiki::Version object with the newest attributes
  # when wiki changes, but a new version is not being created
  def update_latest_version_record
    # only need to update the latest version when not creating a new one
    return if create_new_version?
    versions.last.update_attributes(
      body: body,
      # read_attributes for body_html and raw_structure
      # because we don't want to trigger another rendering
      # by calling our own body_html method
      body_html: read_attribute(:body_html),
      raw_structure: read_attribute(:raw_structure),
      user: user,
      updated_at: Time.now
    )
  end

  def page_for_version(version)
    return 1 unless version
    page_index = versions_since(version) / Wiki.per_page # Version.per_page
    page_index + 1
  end

  protected

  def versions_since(version)
    versions.where("version > #{version.version}").count
  end

  def destroy_versions_after(version_number)
    versions.where('version > ?', version_number).each(&:destroy)
  end
end
