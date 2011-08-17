
define_theme(:parent => 'blueberry') {

  background {
    color '#ECECEC'
  }

  masthead {
    border '1px solid black'
    height '100px'
    css %{
      color: white;
      background: url("/theme/dismod/images/header-bg.jpg") no-repeat scroll center top #111111;
    }
    content {
      vertical_align 'top'
      padding_top '0px'
      html %{
        <div id="logo"></div>
        <div id="header-links">
         <a href="/">Home</a> | <a href="/">Contact</a> | <a href="/">Site Map</a>
        </div>
      }
    }
  }

  footer {
    background_color '#ccc'
    column_count 3
    content {
      html :file => 'extensions/themes/dismod/footer.html'
    }
  }
}

style %{
  #logo {
    background: url("/theme/dismod/images/logo.png") no-repeat scroll center top transparent;
    height: 100px;
    width: 220px;
  }
  #header-links {
    color: #838181;
    font-size: 10px;
    position: absolute;
    right: 20px;
    top: 20px;
  }
  #header-links a {
    color: white;
  }
  #footer {
    background: url("/theme/dismod/images/footer-bg.jpg") no-repeat scroll center top #CCCCCC;
    font-size: 95%;
  }
  #footer .full {
    padding-top: 1em;
    text-align: center;
  }
  #footer h3 {
    color: #666666;
    margin: 0;
    padding: 0 10px;
  }
  #footer ul {
    background: url("/theme/dismod/images/footer-dots.jpg") repeat-x scroll left top transparent;
    list-style: none outside none;
    margin: 10px 0 0;
    padding: 0;
  }
  #footer li {
    background: url("/theme/dismod/images/footer-dots.jpg") repeat-x scroll left bottom transparent;
  }
  #footer a {
    color: #666666;
  }
  #footer li a {
    display: block;
    font-weight: normal;
    padding: 6px 0 6px 10px;
    width: 96%;
  }
}

#  #header {
#    background: url("/theme/dismod/images/header-bg.jpg") no-repeat scroll center top #111111;
#    clear: both;
#    color: #FFFFFF;
#    font: 12px "Lucida Sans Unicode","Lucida Grande","Trebuchet MS",Helvetica,Arial,sans-serif;
#    height: 100px;
#    margin: 0 auto;
#    padding: 0;
#    position: relative;
#    width: 100%;
#  }



