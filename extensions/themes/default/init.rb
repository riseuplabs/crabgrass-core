
# http://css3pie.com/

$border = '1px solid #ccc'

define_theme {

  favicon_png 'favicon.png'
  favicon_ico 'favicon.ico'
  logo 'logo.png'

  grid {
    column {
      count 12
      width '64px'
    }
  }

  margin_p '10px'
  margin_ui '15px'
  margin_gap '20px'

  # avatar sizes
  icon {
    Avatar::SIZES.each do |size, pixels|
      send(size, "#{pixels}px")
    end
  }

  # general color constants that are frequently reused
  color {
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
  }

  #
  # font examples:
  #
  # * bootstrap default: '"Helvetica Neue", Helvetica, Arial, sans-serif'
  # * linux friendly: '"Liberation Sans", sans-serif'
  # * prior crabgrass: 'Verdana, 'Bitstream Vera Sans', Helvetica, sans-serif'
  #
  font {
    default {
      color '#000'
      family 'Verdana, "Liberation Sans", Arial, sans-serif'
      size '13px'
    }
    heading {
      family 'Verdana, "Liberation Sans", Arial, sans-serif'
      weight 'normal'
      color '#000'
      h1_size "#{var(:font_default_size).to_i * 2.25}px"
      h2_size "#{var(:font_default_size).to_i * 1.75}px"
      h3_size "#{var(:font_default_size).to_i * 1.25}px"
      h4_size var(:font_default_size)
    }
  }

  link {
    standard_color "#00e"
    visited_color "#551a8b"
    active_color "#e00"
    underline false
  }

  background {
    color '#fff'
  }

  #
  # for ui elements, like buttons and stuff.
  #
  ui {
    border_radius '4px'
    border_color var(:color_grey)
    fade_color var(:color_lighter)
  }

  masthead {
    style 'full'   # accepts [full | grid]
                   # full -- the masthead stretches the full width of the screen
                   # grid -- the masthead stops at the edge of the grid.
    border {
      color "#000"
    }
    height '100px'
    css "background-color: #f9f9f9;"
    bottom_gap '1g'
    logo url('logo')

#    css %{
#      @include linear-gradient(color-stops(green, red));
#    }
    content {
      vertical_align 'center' # accepts [center | top]

      # for vertical_align 'center'
      height "2.5em" # vertical alignment only works if there is a fixed height

      # for vertical_align 'top'
      padding_top "10px"

      padding "1g"
      html { content_tag :div, current_site.title, id: 'masthead_title' }
    }
    nav {
      # height '40px'
      background '#222'
      tab {
        color '#999'
        hover {
          color '#fff'
        }
        visible {
          color '#fff'
          background '#333'
        }
        active {
          color '#fff'
          background '#000'
        }
      }
    }
  }

  banner {
    width "1200px"  # \ used when processing the
    height "200px"  # / uploaded image.
    padding "30px"
    border "1px solid #000"
    default_background '#3465A4'
    default_foreground '#fff'
    vertical_align 'default'  # [center | top | default]
    font {
      size "36px" # var(:font_heading_h1_size)
    }
    avatar {
      border "2px solid #fff"
    }
    nav {
      padding '6px'
      color '#fff'
      background 'rgba(0,0,0,0.2)'
      active {
        color '#000'
        background var(:background_color)
      }
    }
    # slight inset shadow on the top only
    css "box-shadow: inset 0 6px 6px -5px rgba(0,0,0,0.5);"
  }

  local {
    # border $border
    content {
      border $border
      background 'white'
      padding '1g'
      css false
      shadow false
    }
    sidebar {
      width 2
    }
    sidecolumn {
      width 3
    }
    sidecontent {
      width 4
    }
    single {
      width 12
    }
    nav {
      style 'tabs'
      padding '1g'
      side 'left'   # only left for now.
    }
    sidecolumn {
      # for fun, make the side column width approximate a golden ratio.
      # width (0.3819660113 * var(:grid_column_count).to_i).round
      icon_size 'xsmall'
      icon_size_px var_eval('icon_', :local_sidecolumn_icon_size)
    }
    title {
      background var(:color_lighter)
      border $border
    }
  }

  posts {
    border "1px solid #ddd"
    odd_background var(:color_lighter)
    even_background var(:local_content_background)
  }

  footer {
    border false
    background_color false
    color 'white'
    content {
      space '20px'
      html partial: 'layouts/global/default_footer_content'
    }
  }

  home {
    content {
      html partial: 'session/welcome'
    }
  }

  # all the various z-index values are defined here.
  # these should not ever need to be changed.
  zindex {
    banner_tabs 9      # context banner navigation tabs
    banner_avatar 10   # context banner avatar icon
    menu 99            # masthead navigation menus
    modalbox 200       # modal dialog boxes
    tooltip 300        #
    autocomplete 400   # autocomplete popups
  }

  modalbox {
    background_color "#F3F2EE"
  }
}

style %{
  #masthead_title {
    color: #333;
    font-size: 1.5em;
    // vertically center align:
    line-height: 1.5em;
  }
}
