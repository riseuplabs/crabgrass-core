require 'tmpdir'

module DebugTestHelper
  # prints out a readable version of the response. Useful when using the debugger
  def response_body
    puts @response.body.
      gsub(/<\/?[^>]*>/, "").
      split("\n").
      select{|str|str.present?}.join("\n")
  end
end


