


options(:parent => 'default') {

  background {
    color '#E6E3DC'
  }

  masthead {
    height '60px'
    border 'none'
    css "background-color: #5E9EE3; color: white;"
    nav {
      tab {
        inactive_css %{
          color: white;
          background-color: rgba(0,0,0,0.15);
        }
        active_css %{
          -webkit-box-shadow: inset 1px 1px 2px rgba(255,255,255,0.35);
          -moz-box-shadow: inset 1px 1px 2px rgba(255,255,255,0.35);
          box-shadow: inset 1px 1px 2px rgba(255,255,255,0.35);
        }
      }
      dropdown {
        border_color '#000'
      }
    }
  }

  banner {
    css %{
      -webkit-box-shadow: inset 1px 1px 3px rgba(0,0,0,0.15);
      -moz-box-shadow: inset 1px 1px 3px rgba(0,0,0,0.15);
      box-shadow: inset 1px 1px 3px rgba(0,0,0,0.15);
    }
  }

  local {
    content {
      css %{
        -webkit-box-shadow: 1px 1px 4px #CCC9C3;
        -moz-box-shadow: 1px 1px 4px #CCC9C3;
        box-shadow: 1px 1px 4px #CCC9C3;
      }
    }
  }

}
