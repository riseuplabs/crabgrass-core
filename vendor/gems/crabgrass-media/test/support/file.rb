require 'pathname'

module Support
  module File

    def file(name)
      Pathname(__FILE__) + '..' + '..' + 'files' + name
    end

    def file_info_matches?(file, regex)
      file_info(file) =~ regex
    end

    def file_info(file)
      `file #{file.to_s}`
    end

  end
end

Minitest::Test.send :include, Support::File
