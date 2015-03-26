Themes are defined by folders in `extensions/themes`.

The structure of the folder is like this:

    themename/
      images/        -- directory for theme assets
      init.rb        -- main theme definition
      navigation.rb  -- navigation definition

## Choose a theme

Set the `theme` property in the main configuration yaml file.

## Assets

The "images" is a directory to hold the files that should be publicly available for this theme. The images directory will be available at the url /theme/<themename>/images. If you want to generate a path for a file extensions/themes/themename/images/icon.png, you would do url('icon.png') in init.rb or current_theme.url('icon.png') elsewhere.

## Theme Definition

The init.rb is the main theme definition file.

### Quoting

the theme code does a good job of figuring out if a value, when rendered as css,
should have quotes around it or not. you can force it to not have quotes by
creating a symbol, like so...

    masthead {
      height :"100px"
    }

In this case, this is not needed, because values in px units are not quoted by default anyway.

### HTML blocks

'html' is a special option. it takes either a string, a hash, or a block.

* string: inserts this value directly into the template
* hash: the template will call render() and pass in the hash.
* block: this will get eval'ed in the context of the view.

examples:

    html '<h1>hi mom</h1>'
    html :partial => '/views/layouts/hi.html'
    html { content_tag(:h1, 'hi mom') }

### CSS blocks

'css' is a special option. The text you feed it will get included in the stylesheet as a sass mixin. This means you can make sass calls (using scss format). For example:

    css "background-color: #010203 + #040506;"
    css %{
      $translucent-red: rgba(255, 0, 0, 0.5);
      color: opacify($translucent-red, 0.8);
      background-color: transparentize($translucent-red, 50%);
    }

note: the %{} is a way to define a string in ruby, just not one that is used very often.

## Navigation Definition

The code for the navigation definition is parsed once at startup, but you can include code blocks for any of the values that will get executed at runtime.

