require 'rubygems'
require 'minitest/autorun'
require 'byebug'
require 'yaml'

test_dir = File.dirname(File.expand_path(__FILE__))
require test_dir + '/../lib/greencloth.rb'

SINGLE_FILE_OVERRIDE = if ARGV[0] and ARGV[0] =~ /\.yml/
                         [ARGV[0]].freeze
                       else
                         nil
                       end

class TestMarkup < MiniTest::Test
  def setup
    files = SINGLE_FILE_OVERRIDE || Dir[File.dirname(__FILE__) + '/fixtures/*.yml']
    @fixtures = {}
    files.each do |testfile|
      begin
        YAML.load_documents(File.open(testfile)) do |doc|
          @fixtures[File.basename(testfile)] ||= []
          @fixtures[File.basename(testfile)] << doc
        end
      rescue SyntaxError
        puts "Failed to load #{testfile}"
        raise
      end
    end
    @special = ['outline.yml']
    @markup_fixtures = @fixtures.reject { |key, _value| @special.include? key }
  end

  def test_general_markup
    @markup_fixtures.each do |filename, docs|
      docs.each do |doc|
        assert_markup filename, doc, GreenCloth.new(doc['in']).to_html
      end
    end
  end

  def test_outline
    assert @fixtures['outline.yml']
    @fixtures['outline.yml'].each do |doc|
      assert_markup('outline.yml', doc, GreenCloth.new(doc['in'], '', [:outline]).to_html)
    end
  end

  # def test_sections
  #  return unless @fixtures['sections.yml']
  #  @fixtures['sections.yml'].each do |doc|
  #    greencloth = GreenCloth.new( doc['in'] )
  #    greencloth.wrap_section_html = true
  #    assert_markup('sections.yml', doc, greencloth.to_html)
  #  end
  # end

  protected

  def assert_markup(filename, doc, html)
    in_markup = doc['in']
    expected = doc['out'] || doc['html']
    return unless in_markup and expected
    html.gsub!(/\n+/, "\n")
    expected.gsub!(/\n+/, "\n")
    assert_equal expected, html, <<-EOFAIL.strip_heredoc
      \n------- #{filename} failed: -------
      #{in_markup}
    EOFAIL
  end
end
