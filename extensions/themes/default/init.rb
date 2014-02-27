
# http://css3pie.com/


$border = '1px solid #ccc'

define_theme {

  favicon_png 'favicon.png'
  favicon_ico 'favicon.ico'

  grid {
    column {
      count 12
      width '64px'
      gutter '20px'
      side_gutter '20px'
    }
  }

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

  font {
    default {
      color '#000'
      family "verdana, 'bitstream vera sans', helvetica, sans-serif"
      size '13px'
      line_height '18px'
    }
    heading {
      family "verdana, 'bitstream vera sans', helvetica, sans-serif"
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
    color '#e6e6e6'
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
    border $border
    height '100px'
    css "background-color: #f9f9f9;"
    bottom_gap '1g'

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
      html { content_tag :div, current_site.title, :id => 'masthead_title' }
    }
    nav {
      style 'cutout'  # accepts [cutout | bar]
                     # cutout -- creates tabs cut out from masthead
                     # bar -- creates a separate menu nav bar
      tab {
        padding '1px 14px'
        css false
        active_css false
        inactive_css false
      }
      dropdown {
        background_color 'white'
        border_color '#999'
        hover {
          background_color var(:color_hover)
          border '1px solid #cc9'
        }
      }
    }
  }

  banner {
    # unfortunately, banner padding must be specified in pixels.
    padding "20px"
    border "1px solid #888"
    border_dark "1px solid #000"
    default_background '#999'
    default_foreground '#fff'
    vertical_align 'default'  # [center | top | default]
    font {
      size "36px" # var(:font_heading_h1_size)
    }
    nav {
      style 'cutout' # [cutout | inset | none]
      padding '6px'
    }
    css false
    shadow false
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
    padding "10px"
  }

  footer {
    border false
    background_color false
    color 'white'
    column_count 3
    content {
      #padding '1g'
      html :partial => 'layouts/global/default_footer_content'
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

=begin
masthead {
  nav {}
}
error {}
banner {
  nav { }
}
page {
  sidebar {  }
  titlebox {  }
  comments {  }
}
landing {
  sidebar {  }
}
footer {}
type {}
colors {}
grid {}
=end

=begin
##
## BAD OLD STUFF
##


  ##
  ## general colors
  ##

    link_color "#998675"
    almost_black "#534741"
    warm_grey_text "#998675"
    warm_grey_border "#b89882"
    warm_grey_block "#b89882"
    light_grey_text "#7d7d7d"
    light_grey_border "#ddd"
    lighter_grey_text "#aaa"
    medium_grey_text "#707070"
    medium_grey_border "#bbb"
    blue "#4978bc"
    red "#bd5743"

    posts_bg "#fff"
    footer_bg "#fff"

    general_bg "#E6E3DC"
    content_bg "#fff"

  ##
  ## MASTHEAD
  ##

#"#000000 url(/riseup-masthead.png) 0 0 no-repeat"
  masthead_header_text "#fff"
  masthead_search_text "#fff"

  ##
  ## GLOBAL NAV
  ##

  global_nav_dropdown_bg "#fff"
  global_nav_top_brdr "#a6c0cb"
  global_nav_btm_brdr "#a6c0cb"
  global_nav_bg "#fff"
  global_nav_text "#4978bc"

  ##
  ## BANNER
  ##

  banner_bg "#eef5fc"
  banner_title "#464646"
  banner_button "#78be63"
  banner_brdr_btm "#a6c0cb"

  second_nav_border "#dbdbdb"
  second_nav_bg "#fff"
  second_nav_current "#4978bc"
  second_nav_link "#aaa"

  third_nav_border "#ebebeb"
  third_nav_bg "#fff"
  third_nav_text "#aaa"
  third_nav_current "#4978bc"

  ##
  ## PAGE
  ##

  page_title_bg "#eef5fc"
  page_title_color "#bd5743"
  page_title_h3 "20px"
  page_title_tabs_bg "#eef5fc"
  page_title_tabs_text "#4978bc"

  ##
  ## TYPOGRAPHY
  ##

  headings_font "arial, helvetica, sans-serif"
  general_font "verdana, bitstream vera sans, helvetica, sans-serif"

  h1_size "22px"
  h2_size "18px"
  h3_size "16px"
  h4_size "13px"
  h5_size "11px"
  h6_size "9px"
  h1_color "#534741"
  h2_color "#534741"
  h3_color "#bd5743"
  h4_color "#777"

  ##
  ## OTHER
  ##

  menu_border_color "#000"
  popup_bg "#f3f2ee"
  box1_bg_color "#eee"
  notification "#ffffcc"
=end

