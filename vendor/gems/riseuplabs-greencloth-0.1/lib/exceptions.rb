class GreenClothException < StandardError; end
class GreenClothHeadingError < GreenClothException

  attr_reader :heading, :markup, :regexp

  def initialize(heading, markup, regexp)
    @heading = heading
    @markup = markup
    @regexp = regexp
  end

  def message
    <<-EOM
Failed to create table of contents.
Can't find heading with text:
'#{heading}'
EOM
  end

  def log_message
    "GREENCLOTH ERROR: Can't find heading with text: '#{heading}' in markup '#{markup}' with regexp: '#{regexp}'"
  end

end
