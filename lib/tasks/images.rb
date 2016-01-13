require 'pathname'

def write_file(type, images)
  pathname = stylesheets_dir + "icon_#{type}.css"
  pathname.open('w') do |file|
    images.each do |image|
      str = ".#{image[1]}_#{image[0]} {background-image: url(/images/#{type}/#{image[0]}/#{image[1]}.#{type})}\n"
      file.write(str)
    end
  end
rescue Errno::ENOENT # directory missing
  Dir.mkdir stylesheets_dir
  retry
end

def stylesheets_dir
  rails_root + 'public/stylesheets'
end

def images_dir
  rails_root + 'public/images'
end

def svg_dir
  rails_root + 'doc/image-sources'
end

# replacement for Rails.root - which is not available here.
def rails_root
  path = Pathname.new File.dirname(__FILE__)
  path.realpath + '../..'
end

namespace :cg do
  namespace :images do

    desc "updates the css for all the icons"
    task :update_css do
      images = []
      Dir.chdir(images_dir + 'png') do
        ['16','48'].each do |dir|
          Dir.chdir(dir) do
            Dir.glob('*.png') do |png_file|
              images << [dir,png_file.sub(/\.png$/,'')]
              putc '.'; STDOUT.flush;
            end
          end
        end
      end
      images.sort!{|a,b|
        if a[0] == b[0]
          a [1] <=> b[1]
        else
          a[0] <=> b[0]
        end
      }
      ['png','gif'].each do |type|
        write_file(type, images)
      end
    end

    desc "render doc/image-sources/*.svg to public/images/png (requires inkscape)"
    task :render_svg do
      Dir.chdir(svg_dir) do
        size = '48'
        Dir.chdir(size) do
          Dir.glob('*.svg') do |svg_file|
            dest_file = File.join(images_dir, 'png', size, svg_file.sub('.svg','.png'))
            putc '.'; STDOUT.flush
            `inkscape -e #{dest_file} -w #{size} -h #{size} --file #{svg_file}`
          end
        end
      end
    end


  end
end

