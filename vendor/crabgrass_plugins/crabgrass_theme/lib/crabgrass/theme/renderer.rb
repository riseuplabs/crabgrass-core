##
## THEME CSS RENDERING
##

module Crabgrass::Theme::Renderer

  public

  # returns rendered css from a sass source file

  def render_css(file)
    if Rails.env == 'development'
      # in dev mode, the only reason to render the css is if the theme definition
      # changed and the cached css was destroyed. In this case, we better reload
      # the theme. Normally, this will get triggered automatically when we call
      # theme.stylesheet_url. However, sometimes this never gets called, like if
      # you are manually refreshing the url for the stylesheet for debugging purposes.
      reload!
    end
    sass_text = generate_sass_text(file)
    Sass::Engine.new(sass_text, sass_options).render
  end

  # print out a nice error message if anything goes wrong
  def error_response(exception)
    txt = []
    txt << "<html><body>"
    txt << "<h2>#{exception}</h2>"
    txt << "<blockquote>Line number: #{exception.sass_line}<br/>"
    txt << "File: #{exception.sass_filename}</blockquote>"
    if !exception.sass_filename.nil? and exception.sass_filename !~ /screen/
      print_sass_source(txt, File.read(exception.sass_filename).split("\n"))
    end
    print_sass_source(txt, exception.sass_template.split("\n"))
    txt << "</body></html>"
    txt.join("\n")
  end

  private

  def print_sass_source(txt, data)
    line_number = 1
    txt << "<pre>"
    data.each do |line|
      txt << "%4.i  %s" % [line_number, line]
      line_number += 1
    end
    txt << "</pre>"
  end

  # takes a sass file, and prepends the variable declarations for this theme.
  # returns a text blob that is the completed sass.

  def generate_sass_text(file)
    # reload_theme_if_needed
    sass = []
    sass << '// VARIABLES FROM %s' % @directory
    data.collect do |key,value|
      if skip_variable?(key)
        next
      elsif special_variable?(key) and value
        sass += handle_special_variable(key, value)
      else
        sass << handle_normal_variable(key,value)
      end
    end
    sass << ""
    sass << '// FILE FROM %s' % sass_source_path(file)
    sass << File.read( sass_source_path(file) )
    if @style and file == Crabgrass::Theme::CORE_CSS_SHEET
      sass << '// CUSTOM CSS FROM THEME'
      sass << @style
    end
    return sass.join("\n")
  end

  #
  # when definiting sass variables, it matters a lot whether the value
  # is quoted or not, because this is passed on to css.
  # see http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html#variables_
  #
  # this method determines if we should puts quotes or not.
  #
  # For CSS, when generally don't ever need quotes. However,
  # because all theme variables get defined as sass variables, even
  # ones that are not used for CSS, we need to make sure we quote
  # anything that would require quotes in CSS.
  #
  def quote_sass_variable?(value)
    if value =~ /^#/
      false
    elsif value =~ /(px|em|%)$/
      false
    elsif value =~ /[\(\)]/
      false
    elsif value =~ /^\dpx (solid|dotted)/
      # looks like a boder definition
      false
    elsif value =~ /aqua|black|blue|fuchsia|gray|green|lime|maroon|navy|olive|purple|red|silver|teal|white|yellow|light|dark/
      value =~ / /
    elsif value =~ /serif/
      false
    elsif value.is_a? String
      true
    else
      false
    end
  end

  def mixin_variable?(key)
    key.to_s =~ /_css$/
  end

  def shadow_variable?(key)
    key.to_s =~ /_shadow$/
  end

  def special_variable?(key)
    shadow_variable?(key) or mixin_variable?(key)
  end

  def skip_variable?(key)
    key.to_s =~ /_html$/
  end

  def handle_normal_variable(key,value)
    if quote_sass_variable?(value)
      '$%s: "%s";' % [key,value]
    else
      '$%s: %s;' % [key,value]
    end
  end

  def handle_special_variable(key, value)
    sass = []
    if mixin_variable?(key)
      sass << "@mixin #{key} {"
      sass << value
      sass << "}"
      sass << '$%s: true;' % key
    elsif shadow_variable?(key)
      unless value.is_a? Array
        value = [value]
      end
      sass << "@mixin #{key} {"
      value.each do |args|
        border = "%s %s %s %s %s" % [(args[:inset] ? 'inset' : ''), (args[:x]||'1px'), (args[:y]||'1px'), (args[:blur]||'4px'), (args[:color]||'#333')]
        sass << "-webkit-box-shadow: #{border};"
        sass << "-moz-box-shadow: #{border};"
        sass << "box-shadow: #{border};"
      end
      sass << "}"
      sass << '$%s: true;' % key
    end
    return sass
  end


  # given a css sheet name, return the corresponding sass file
  # e.g.
  #   'screen' => '/usr/apps/crabgrass/app/stylesheets/screen.sass'

  def sass_source_path(sheet_name)
    Crabgrass::Theme::SASS_ROOT.join(sheet_name + '.scss')
  end

  # given a css sheet name, return the corresponding themed css file
  # e.g.
  #   'screen' => '/usr/apps/crabgrass/public/theme/default/screen.css'

  def css_destination_path(sheet_name)
    File.join(@public_directory, sheet_name.empty? ? "" : sheet_name + '.css')
  end

  # http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html#options
  def sass_options
    {
      :load_paths => [Crabgrass::Theme::SASS_ROOT],
      :debug_info => false,
      :style => :nested,
      :line_comments => false,
      :syntax => :scss,
      :cache => false
    }
  end

end
