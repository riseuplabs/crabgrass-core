module Common::Ui::LayoutHelper
  protected

  ##
  ## TITLE
  ##

  def html_title
    ([@options.try.title] + context_titles + [current_site.title]).compact.join(' - ')
  end

  ##
  ## CLASS
  ##

  def local_class
    if @page
      @page.definition.url
    elsif @group
      @group.type.try.underscore || 'group'
    elsif @user
      @user.class.name.underscore
    end
  end

  def favicon_link
    if current_theme[:favicon_png] and current_theme[:favicon_ico]
      format('<link rel="shortcut icon" href="%s" type="image/x-icon" /><link rel="icon" href="%s" type="image/x-icon" />', current_theme.url(:favicon_ico), current_theme.url(:favicon_png))
    elsif current_theme[:favicon]
      format('<link rel="icon" href="%s" type="image/x-icon" />', current_theme.url(:favicon))
    end.html_safe
  end

  ##
  ## COLUMN SPANS
  ##

  def center_span_class(column_type)
    side_column_count = current_theme["local_#{column_type}_width"]
    center_column_count = current_theme.grid_column_count - side_column_count
    ["col-xs-12", "col-md-#{center_column_count}"]
  end

  def side_span_class(column_type)
    column_count = current_theme["local_#{column_type}_width"]
    ["col-xs-12", "col-md-#{column_count}"]
  end

  ##
  ## LAYOUT STRUCTURE
  ##

  # builds and populates a table with the specified number of columns
  def column_layout(cols, items, options = {}, &block)
    lines = []
    count = items.size
    rows = (count.to_f / cols).ceil
    width = (100.to_f / cols.to_f).to_i if options[:balanced]
    lines << "<table class='#{options[:class]}' style='#{options[:style]}'>" unless options[:skip_table_tag]
    if options[:header]
      lines << "<tr><th colspan='#{cols}'>#{options[:header]}</th></tr>"
    end
    for r in 1..rows
      lines << ' <tr>'
      for c in 1..cols
        cell = ((r - 1) * cols) + (c - 1)
        next unless items[cell]
        lines << "  <td valign='top' #{"style='width:#{width}%'" if options[:balanced]}>"
        lines << if block
                   yield(items[cell])
                 else
                   format('  %s', items[cell])
                 end
        # lines << "r%s c%s i%s" % [r,c,cell]
        lines << '  </td>'
      end
      lines << ' </tr>'
    end
    lines << '</table>' unless options[:skip_table_tag]
    lines.join("\n").html_safe
  end

  #
  # acts like haml_tag, capture_haml, or haml_concat, depending on how it is called.
  #
  # two or more args             --> like haml_tag
  # one arg and a block          --> like haml_tag
  # zero args and a block        --> like capture_haml
  # one arg and no block         --> like haml_concat
  #
  # additionally, we allow the use of more than one class.
  #
  # some examples of these usages:
  #
  #   def display_robot(robot)
  #     haml do                                # like capture_haml
  #       haml '.head', robot.head_html        # like haml_tag
  #       haml '.body.metal', robot.body_html  # like haml_tag, but with multiple classes
  #       haml '<a href="/x">link</a>'         # like haml_concat
  #     end
  #   end
  #
  # wrapping the helper in a capture_haml call is very useful, because then
  # the helper can be used wherever a normal helper would be.
  #
  def haml(name = nil, *args, &block)
    if name.present?
      if args.empty? and block.nil?
        haml_concat name
      else
        if name =~ /^(.*?\.[^\.]*)(\..*)$/
          # allow chaining of classes if there are multiple '.' in the first arg
          name = Regexp.last_match(1)
          classes = Regexp.last_match(2).tr('.', ' ')
          hsh = args.detect { |i| i.is_a?(Hash) }
          unless hsh
            hsh = {}
            args << hsh
          end
          hsh[:class] = classes
        end
        haml_tag(name, *args, &block)
      end
    else
      capture_haml(&block)
    end
  end

  #
  # joins an array of elements together using commas.
  #
  def comma_join(*args)
    args.select(&:present?).join(', ')
  end
end
