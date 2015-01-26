define_theme(parent: 'blueberry') {

  body {
    css "background: $background_color url(images/crows.png) no-repeat center bottom"
  }

  footer {
    content {
      html partial: 'themes/riseup/footer'
    }
  }


}
