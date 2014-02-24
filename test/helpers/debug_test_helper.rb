require 'tmpdir'

module DebugTestHelper
  # prints out a readable version of the response. Useful when using the debugger
  def response_body
    puts @response.body.
      gsub(/<\/?[^>]*>/, "").
      split("\n").
      select{|str|str.present?}.join("\n")
  end

  # prints a notice that we are skipping a particular test
  def skip_msg(id, msg)
    print_test_msg(id, "SKIP: #{msg} (#{caller.first})")
    skip(msg)
  end

  #
  # allow tests to print some messages at the end of all tests.
  #
  # Minitest is supposed to do this, according to the documentation,
  # when you call skip(), but I can't figure out how to get it to
  # actually print.
  #
  def print_test_msg(id, msg)
    DebugTestHelper.initialize_print_msg_dir
    File.open(DebugTestHelper.test_tmp_file(id), 'w') do |f|
      f.write(msg)
    end
  end

  def self.print_delayed_test_messages
    puts
    Dir.glob(File.join(test_tmp_dir, '*.msg')).each do |file|
      content = File.read(file)
      if content
        puts content
      end
      File.unlink(file)
    end
  end

  private

  def self.initialize_print_msg_dir
    Dir.mkdir(test_tmp_dir) unless Dir.exists?(test_tmp_dir)
  end

  def self.test_tmp_dir
    File.join(Dir.tmpdir, 'crabgrass-test')
  end

  def self.test_tmp_file(filename)
    File.join(test_tmp_dir, "#{filename}.msg")
  end

end


