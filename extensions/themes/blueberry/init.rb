


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
    shadow :inset => true, :x => '1px', :y => '1px', :blur => '3px', :color => 'rgba(0,0,0,0.15)'
  }

  local {
    content {
       shadow :x => '1px', :y => '1px', :color => '#CCC9C3', :blur => '4px'
    }
  }

}
