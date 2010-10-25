require 'pathname'

def write_file(type, images)
  File.open(images_dir + "/../stylesheets/icon_#{type}.css", 'w') do |file|
    images.each do |image|
      str = ".#{image[1]}_#{image[0]} {background-image: url(/images/#{type}/#{image[0]}/#{image[1]}.#{type})}\n"
      file.write(str)
    end
  end
end

def images_dir
  Pathname.new(File.dirname(__FILE__) + '/../../public/images').realpath.to_s
end

namespace :cg do
  namespace :images do 

    desc "updates the css for all the icons"
    task :update_css do
      images = []
      Dir.chdir(images_dir) do 
        Dir.chdir('png') do
          ['16','48'].each do |dir|
            Dir.chdir(dir) do 
              Dir.glob('*.png') do |png_file|
                images << [dir,png_file.sub(/\.png$/,'')]
                putc '.'; STDOUT.flush;
              end
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

    desc "update the gif icons by converting the png icons"
    task :update_gif do
      white_png = images_dir + '/png/white.png'
      Dir.chdir(images_dir) do 
        Dir.chdir('png') do
          ['16','48'].each do |dir|
            Dir.chdir(dir) do 
              Dir.glob('*.png') do |png_file|
                gif_file = "%s/gif/%s/%s" % [images_dir,dir, png_file.sub('.png','.gif')]
                putc '.'; STDOUT.flush;
                width, height = `gm identify -format '%wx%h' #{png_file}`.gsub(/\s/,'').split('x')
                system('gm', 'composite', png_file, white_png, '-geometry', "#{width}x#{height}", 'temp_file.png')
                system('gm', 'convert', 'temp_file.png', '-transparent', '#fff', gif_file)
                File.unlink('temp_file.png')
              end
            end
          end
        end
      end
    end

  end
end

  #File.open('../../mods/design_tester/app/views/design/reference/Images/icons.html','w') do |file|
  #  images.each do |image|
  #    if image[0] == '16'
  #      klass = 'small_icon'
  #    else
  #      klass = 'big_icon'
  #    end
  #    file.write %(<div class="#{klass} #{image[1]}_#{image[0]}">#{image[1]}_#{image[0]}</div>\n)
  #  end
  #end

