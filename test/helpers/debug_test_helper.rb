module DebugTestHelper
  # prints out a readable version of the response. Useful when using the debugger
  def response_body
    puts @response.body.
      gsub(/<\/?[^>]*>/, "").
      split("\n").
      select{|str|str.present?}.join("\n")
  end

  # prints a notice that we are skipping a particular test
  #
  # normally, the skip is indicated with a single 'S', but if the env var
  # INFO is set, then it prints out where the skip happened, with a message.
  #
  def skip(msg)
    if ENV['INFO']
      info "<< skip -- #{caller.first} -- #{msg} >>"
    else
      putc 'S'
    end
  end

end


