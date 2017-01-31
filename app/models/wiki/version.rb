class Wiki::Version < ActiveRecord::Base


  before_destroy :confirm_existance_of_other_version

  def self.most_recent
    order('version DESC')
  end

  self.per_page = 10

  def confirm_existance_of_other_version
    self.previous || self.next || false
  end

  def to_s
    to_param
  end

  def to_param
    self.version.to_s
  end

  def diff_id
    "#{previous.to_param}-#{self.to_param}"
  end

  def body_html
    read_attribute(:body_html).try.html_safe
  end

end
