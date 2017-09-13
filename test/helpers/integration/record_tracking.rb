module RecordTracking
  protected

  # keep track of all records created
  attr_writer :records

  def records
    @records ||= {}
  end
end
