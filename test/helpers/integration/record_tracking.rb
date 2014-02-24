module RecordTracking

  protected

  # keep track of all records created
  attr_accessor :records

  def setup
    super
    @records = {}
  end

  def teardown
    @records.each_value do |record|
      # update all associations - they might already be gone.
      record.reload
      # destroy is protected for groups. We want to use
      # it never the less as we do not care who destroyed it.
      record.send :destroy
    end
    super
  end

  def cleanup_user
    if @user
      User.find_by_login(@user.login).try.destroy
    end
    @user = nil
  end

  def cleanup_page
    if @page
      Page.find_by_name(@page.name).try.destroy
    end
    @page = nil
  end

end
