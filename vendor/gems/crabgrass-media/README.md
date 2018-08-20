Crabgrass::Media is the Media engine of Crabgrass.

Crabgrass is a web application designed for activist groups to be better able to collaborate online. Mostly, it is a glorified wiki with fine-grain control over access rights.

Crabgrass::Media is a rails engine to do media transformations.

You can add new media transformations by subclassing Transmogrifier.

Example usage:

```ruby
  transmog = Media.transmogrifier(:input_file => 'myfile.odt', :output_file => 'myfile.jpg')
  status = transmog.run do |progress|
    puts progress
  end
```

Tests require the 'file' utility to be installed to determine the file
type of the created files.

Crabgrass and Crabgrass::Media are based on Ruby on Rails and MySQL.
They are released under the AGPL license, version 3.
