Theme Stylesheets
===========================

These are the stylesheets configured in themes. Note that
/app/assets/stylesheets also contains the stylesheets that can not be
configured in themes.

`screen.scss` -- main application stylesheet

`_bootstrap-VERSION.scss` -- includes the files we want from bootstrap/*

`bootstrap-VERSION/` -- Twitter bootstrap converted to SCSS. From
https://github.com/twbs/bootstrap- sass. The current gem version is
incompatible with Rails 3, but we just use the .scss files directly anyway.

Themes and stylesheets
===========================

All the variables defined in a theme are made available to screen.scss.

This is done by auto-generating a SCSS file for each theme that looks like this:

    // VARIABLES FROM extensions/themes/blueberry
    $masthead_style: "full";
    $posts_border: 1px solid #ddd;
    $local_sidecolumn_width: 7;
    $color_dim: #999;
    ...
    // FILE FROM app/stylesheets/screen.scss
    <contents of screen.scss>

Every theme has a different URL for it's screen.scss. For example, the theme
"blueberry" uses this URL:

    /theme/blueberry/screen.css

