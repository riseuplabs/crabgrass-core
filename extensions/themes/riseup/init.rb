define_theme(parent: 'default') {

  masthead {
    logo url('logo')
  }

  footer {
    content {
      html partial: 'themes/riseup/footer'
    }
  }

  home {
    content {
      html partial: 'themes/riseup/home'
    }
  }

  link {
    # this is the color of the menu background in the banner navigation.
    # (banner background with a dark overlay)
    # It works both for normal fonts and for headings
    standard_color "#2a5183"
  }

}

style %{
  body {
    background-color: #555;
  }
  #middle {
    border-bottom: 1px solid #000;
  }
  #footer {
    select {
      border: 1px solid #000;
      color: #000;
      background-color: #999;
    }
    background: url("/theme/riseup/images/crows.png") 50% 6em no-repeat;
    padding-top: 20px;
    color: #ddd;
    a {
      color: #eee;
      //text-decoration: underline;
    }
  }
}
