module Common::Ui::LayoutHelper

  protected

  ##
  ## TITLE
  ##

  def html_title
    ([@html_title] + context_titles + [current_site.title]).compact.join(' - ')
  end

  ##
  ## STYLESHEET
  ##

  # as needed stylesheets:
  # rather than include every stylesheet in every request, some stylesheets are
  # only included if they are needed. See Application#stylesheet()

  def optional_stylesheets
    stylesheet = controller.class.stylesheet || {}
    return [stylesheet[:all], @stylesheet, stylesheet[params[:action].to_sym]].flatten.compact.collect{|i| "as_needed/#{i}"}
  end

  # crabgrass_stylesheets()
  # this is the main helper that is in charge of returning all the needed style
  # elements for HTML>HEAD.

  def crabgrass_stylesheets
    lines = []

    lines << stylesheet_link_tag( current_theme.stylesheet_url('screen') )
    lines << stylesheet_link_tag('icon_png')
    lines << optional_stylesheets.collect do |sheet|
       stylesheet_link_tag( current_theme.stylesheet_url(sheet) )
    end
    lines << '<style type="text/css">'
      lines << @content_for_style
    lines << '</style>'
    lines << '<!--[if IE 6]>'
      lines << stylesheet_link_tag('ie6')
      lines << stylesheet_link_tag('icon_gif')
    lines << '<![endif]-->'
    lines << '<!--[if IE 7]>'
      lines << stylesheet_link_tag('ie7')
      lines << stylesheet_link_tag('icon_gif')
    lines << '<![endif]-->'
    if language_direction == "rtl"
      lines << stylesheet_link_tag( current_theme.stylesheet_url('rtl') )
    end
    lines.join("\n").html_safe
  end

  def favicon_link
    if current_theme[:favicon_png] and current_theme[:favicon_ico]
    '<link rel="shortcut icon" href="%s" type="image/x-icon" /><link rel="icon" href="%s" type="image/x-icon" />' % [current_theme.url(:favicon_ico), current_theme.url(:favicon_png)]
    elsif current_theme[:favicon]
      '<link rel="icon" href="%s" type="image/x-icon" />' % current_theme.url(:favicon)
    end.html_safe
  end

  ##
  ## JAVASCRIPT
  ##

  SPROCKETS_PREFIX = '/static/'

  #
  # Includes the correct javascript tags for the current request.
  # See ApplicationController#javascript for details.
  #
  def javascript_include_tags
    scripts = controller.class.javascript || {}
    files = [:prototype, :libraries, :crabgrass]
    files += [scripts[:all], scripts[params[:action].to_sym]].flatten.compact.collect{|i| "as_needed/#{i}"}

    includes = []
    files.each do |file|
      includes << javascript_include_tag(SPROCKETS_PREFIX + file.to_s)
    end
    return includes
  end

  def crabgrass_javascripts
    lines = javascript_include_tags

    ## FIXME: this uses '@_content_for[:x]' to get data chunks previously
    ##   added via 'content_for()'. For later Rails versions (> 3.1 ??)
    ##   this needs to be changed to '@view_flow.get(:x)'.

    # inline script code
    lines << '<script type="text/javascript">'
    #lines << localize_modalbox_strings
    lines << @_content_for[:script]
    lines << 'document.observe("dom:loaded",function(){'
    lines << detect_browser_js
    lines << @_content_for[:dom_loaded]
    lines << '});'
    lines << '</script>'

    # make all IEs behave like IE 9
    lines << '<!--[if lt IE 9]>'
      lines << javascript_include_tag(SPROCKETS_PREFIX + 'ie')
    lines << '<![endif]-->'

    # run firebug lite in dev mode for ie
    if Rails.env == 'development'
      lines << '<!--[if IE]>'
      lines << "<script type='text/javascript' src='http://getfirebug.com/firebug-lite-beta.js'></script>"
      lines << '<![endif]-->'
    end

    lines.join("\n").html_safe
  end

  ##
  ## BANNER
  ##

  # banner stuff
  #def banner_style
  #  "background: #{@banner_style.background_color}; color: #{@banner_style.color};" if @banner_style
  #end
  #def banner_background
  #  @banner_style.background_color if @banner_style
  #end
  #def banner_foreground
  #  @banner_style.color if @banner_style
  #end

  ##
  ## CONTEXT STYLES
  ##

  #def background_color
  #  "#ccc"
  #end
  #def background
  #  #'url(/images/test/grey-to-light-grey.jpg) repeat-x;'
  #  'url(/images/background/grey.png) repeat-x;'
  #end

  # return all the custom css which might apply just to this one group
#  def context_styles
#    style = []
#     if @banner
#       style << '#banner {%s}' % banner_style
#       style << '#banner a.name_link {color: %s; text-decoration: none;}' %
#                banner_foreground
#       style << '#topmenu li.selected span a {background: %s; color: %s}' %
#                [banner_background, banner_foreground]
#     end
#    style.join("\n")
#  end

  ##
  ## LAYOUT STRUCTURE
  ##

  # builds and populates a table with the specified number of columns
  def column_layout(cols, items, options = {}, &block)
    lines = []
    count = items.size
    rows = (count.to_f / cols).ceil
    if options[:balanced]
      width= (100.to_f/cols.to_f).to_i
    end
    lines << "<table class='#{options[:class]}'>" unless options[:skip_table_tag]
    if options[:header]
      lines << options[:header]
    end
    for r in 1..rows
      lines << ' <tr>'
      for c in 1..cols
         cell = ((r-1)*cols)+(c-1)
         next unless items[cell]
         lines << "  <td valign='top' #{"style='width:#{width}%'" if options[:balanced]}>"
         if block
           lines << yield(items[cell])
         else
           lines << '  %s' % items[cell]
         end
         #lines << "r%s c%s i%s" % [r,c,cell]
         lines << '  </td>'
      end
      lines << ' </tr>'
    end
    lines << '</table>' unless options[:skip_table_tag]
    lines.join("\n").html_safe
  end

  ##
  ## PARTIALS
  ##

  def dialog_page(options = {}, &block)
    block_to_partial('common/dialog_page', options, &block)
  end

  ##
  ## MISC. LAYOUT HELPERS
  ##

  #
  # takes an array of objects and splits it into two even halves. If the count
  # is odd, the first half has one more than the second.
  #
  def even_split(arry)
    cutoff = (arry.count + 1) / 2
    return [arry[0..cutoff-1], arry[cutoff..-1]]
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
  def haml(name=nil, *args, &block)
    if name.present?
      if args.empty? and block.nil?
        haml_concat name
      else
        if name =~ /^(.*?\.[^\.]*)(\..*)$/
          # allow chaining of classes if there are multiple '.' in the first arg
          name = $1
          classes = $2.gsub('.',' ')
          hsh = args.detect{|i| i.is_a?(Hash)}
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

  #
  # *NEWUI
  #
  # provides a block for main container
  #
  # content_starts_here do
  #   %h1 my page
  #
  #def content_starts_here(&block)
  #  capture_haml do
  #    haml_tag :div, :id =>'main-content' do
  #      haml_concat capture_haml(&block)
  #    end
  #  end
  #end

  ##
  ## CUSTOMIZED STUFF
  ##

  # build a masthead, using a custom image if available
 # def custom_masthead_site_title
 #   appearance = current_site.custom_appearance
 #   if appearance and appearance.masthead_asset
 #     # use an image
 #     content_tag :div, '', :id => 'site_logo_wrapper' do
 #       content_tag :a, :href => '/', :alt => current_site.title do
 #         image_tag(appearance.masthead_asset.url, :id => 'site_logo')
 #       end
 #     end
 #   else
      # no image
 #     content_tag :h2, current_site.title
      # <h2><%= current_site.title %></h2>
 #   end
 # end

 # def masthead_container
 #   locals = {}
#    appearance = current_site.custom_appearance
#    if appearance and appearance.masthead_asset and current_site.custom_appearance.masthead_enabled
#      height = appearance.masthead_asset.height
#      bgcolor = (appearance.masthead_background_parameter == 'white') ? '' : '#'
#      bgcolor = bgcolor+appearance.masthead_background_parameter
#      locals[:section_style] = "height: #{height}px"
#      locals[:style] = "background: url(#{appearance.masthead_asset.url}) no-repeat; height: #{height}px;"
#      locals[:render_title] = false
#    else
 #     locals[:section_style] = ''
 #     locals[:style] = ''
 #     locals[:render_title] = true
#    end
 #   render :partial => 'layouts/base/masthead', :locals => locals
 # end

  ##
  ## declare strings used for logins
  ##
  def login_context
    @login_context ||={
      :strings => {
        :login           => I18n.t(:login),
        :username        => I18n.t(:username),
        :password        => I18n.t(:password),
        :forgot_password => I18n.t(:forgot_password_link),
        :create_account  => I18n.t(:signup_link),
        :redirect        => params[:redirect] || request.request_uri,
        :token           => form_authenticity_token
      }
    }
  end

  private

  # for susy to work, we need to add class 'webkit' to body when the browser
  # is a webkit browser. I am not sure if this should be done on dom:loaded or
  # before.
  def detect_browser_js
    # "document.observe('dom:loaded',function(){if(/khtml|webkit/i.test(navigator.userAgent)){$$('body').first().addClassName('webkit');}});"
    "if(/khtml|webkit/i.test(navigator.userAgent)){$$('body').first().addClassName('webkit');}"
  end

end
