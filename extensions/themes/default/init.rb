
# http://css3pie.com/

$border = '1px solid #ccc'

define_theme do
  favicon_png 'favicon.png'
  favicon_ico 'favicon.ico'
  logo 'logo.png'

  grid do
    column do
      count 12
      width '64px'
    end
  end

  margin_p '10px'
  margin_ui '15px'
  margin_gap '20px'

  # avatar sizes
  icon do
    Avatar::SIZES.each do |size, pixels|
      send(size, "#{pixels}px")
    end
  end

  # general color constants that are frequently reused
  color do
    dim '#999'
    bright '#f33'

    # used for borders, typically
    grey '#ddd'

    # used for a subtle highlight (e.g. table headings)
    light '#eee'

    # used for barely visible highlight (e.g. table rows).
    lighter '#f5f5f5'

    # used as :hover background for mouse-over clickable areas
    hover '#ffd'
  end

  #
  # font examples:
  #
  # * bootstrap default: '"Helvetica Neue", Helvetica, Arial, sans-serif'
  # * linux friendly: '"Liberation Sans", sans-serif'
  # * prior crabgrass: 'Verdana, 'Bitstream Vera Sans', Helvetica, sans-serif'
  #
  font do
    default do
      color '#000'
      family 'Verdana, "Liberation Sans", Arial, sans-serif'
      size '13px'
    end
    heading do
      family 'Verdana, "Liberation Sans", Arial, sans-serif'
      weight 'normal'
      color '#000'
      h1_size "#{var(:font_default_size).to_i * 2.25}px"
      h2_size "#{var(:font_default_size).to_i * 1.75}px"
      h3_size "#{var(:font_default_size).to_i * 1.25}px"
      h4_size var(:font_default_size)
    end
  end

  link do
    standard_color '#2a5183'
    visited_color '#551a8b'
    active_color '#e00'
    underline false
  end

  background do
    color '#fff'
  end

  #
  # for ui elements, like buttons and stuff.
  #
  ui do
    border_radius '4px'
    border_color var(:color_grey)
    fade_color var(:color_lighter)
  end

  masthead do
    style 'full' # accepts [full | grid]
    # full -- the masthead stretches the full width of the screen
    # grid -- the masthead stops at the edge of the grid.
    border do
      color '#000'
    end
    height '100px'
    css 'background-color: #f9f9f9;'
    bottom_gap '1g'
    logo url('logo')

    #    css %{
    #      @include linear-gradient(color-stops(green, red));
    #    }
    content do
      vertical_align 'center' # accepts [center | top]

      # for vertical_align 'center'
      height '2.5em' # vertical alignment only works if there is a fixed height

      # for vertical_align 'top'
      padding_top '10px'

      padding '1g'
      html { content_tag :div, current_site.title, id: 'masthead_title' }
    end
    nav do
      # height '40px'
      background '#222'
      tab do
        color '#999'
        hover do
          color '#fff'
        end
        visible do
          color '#fff'
          background '#333'
        end
        active do
          color '#fff'
          background '#000'
        end
      end
    end
  end

  banner do
    width '1200px'  # \ used when processing the
    height '200px'  # / uploaded image.
    padding '20px'
    border '1px solid #000'
    default_background '#3465A4'
    default_foreground '#fff'
    vertical_align 'default' # [center | top | default]
    font do
      size '36px' # var(:font_heading_h1_size)
    end
    avatar do
      border '2px solid #fff'
    end
    nav do
      padding '6px'
      color '#fff'
      background 'rgba(0,0,0,0.2)'
      active do
        color '#000'
        background var(:background_color)
      end
    end
    # slight inset shadow on the top only
    css 'box-shadow: inset 0 6px 6px -5px rgba(0,0,0,0.5);'
  end

  local do
    # border $border
    content do
      border $border
      background 'white'
      padding '1g'
      css false
      shadow false
    end
    sidebar do
      width 2
    end
    sidecolumn do
      width 3
    end
    sidecontent do
      width 4
    end
    single do
      width 12
    end
    nav do
      style 'tabs'
      padding '1g'
      side 'left' # only left for now.
    end
    sidecolumn do
      # for fun, make the side column width approximate a golden ratio.
      # width (0.3819660113 * var(:grid_column_count).to_i).round
      icon_size 'xsmall'
      icon_size_px var_eval('icon_', :local_sidecolumn_icon_size)
    end
    title do
      background var(:color_lighter)
      border $border
    end
  end

  posts do
    border '1px solid #ddd'
    odd_background var(:color_lighter)
    even_background var(:local_content_background)
  end

  footer do
    border false
    background_color false
    color 'white'
    content do
      space '20px'
      html partial: 'layouts/global/default_footer_content'
    end
  end

  home do
    content do
      html partial: 'common/session/welcome'
    end
  end

  # all the various z-index values are defined here.
  # these should not ever need to be changed.
  zindex do
    banner_tabs 9      # context banner navigation tabs
    banner_avatar 10   # context banner avatar icon
    menu 99            # masthead navigation menus
    modalbox 200       # modal dialog boxes
    tooltip 300        #
    autocomplete 400   # autocomplete popups
  end

  modalbox do
    background_color '#F3F2EE'
  end
end

style %(
  #masthead_title {
    color: #333;
    font-size: 1.5em;
    // vertically center align:
    line-height: 1.5em;
  }
)
