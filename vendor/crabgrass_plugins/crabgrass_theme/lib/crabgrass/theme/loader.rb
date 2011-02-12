##
## THEME LOADING AND STORAGE
##

require 'fileutils'
require 'pathname'

module Crabgrass::Theme::Loader
 
  public

  def load
    info 'loading theme %s' % @directory, 1

    # load and eval theme
    init_paths.each do |file|
      evaluate_theme_definition(file)
    end

    # in production, clear the cache once at startup.
    clear_cache if RAILS_ENV == 'production'

    # create the theme's public directory and link the theme's
    # 'images' directory to it.
    ensure_dir(@public_directory)
    symlink("#{@directory}/images", "#{@public_directory}/images")
  end

  private

  def self.create_and_load(theme_name)
    theme = Crabgrass::Theme.new( theme_name )
    theme.load
    theme
  end

  def evaluate_theme_definition(file)
    eval(IO.read(file), binding, file)
  end

  def init_paths
    paths = []
    paths << @directory+'/init.rb' if File.exist?(@directory+'/init.rb')
    paths << @directory+'/navigation.rb' if File.exist?(@directory+'/navigation.rb')
    raise 'ERROR: no theme definition files in %s' % @directory unless paths.any?
    return paths
  end

  # ensures relative path symlink
  def symlink(src,dst)
  
    # this must come before the pathname stuff, because realpath will try to resolve
    # any existing bad symlinks
    if File.symlink?(dst)
      FileUtils.rm(dst)
    elsif File.exists?(dst)
      raise 'For the theme to work, the file "%s" should not exist.' % dst
    end

    real_src_path = Pathname.new(src).realpath
    real_dst_dir = Pathname.new(File.dirname(dst)).realpath

    relative_path = real_src_path.relative_path_from(real_dst_dir)
    FileUtils.ln_s(relative_path, real_dst_dir)
  end

  # ensures the directory exists
  def ensure_dir(dir)
    unless File.exists?(dir)
      FileUtils.mkdir_p(dir)
    end
    unless File.directory?(dir)
      raise 'For the theme to work, "%s" must be a directory.' % dir
    end
  end  
  
end

