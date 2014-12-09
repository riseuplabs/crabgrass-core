module RecordTracking

  protected

  # keep track of all records created
  attr_accessor :records

  def setup
    super
    @records = {}
  end

end
