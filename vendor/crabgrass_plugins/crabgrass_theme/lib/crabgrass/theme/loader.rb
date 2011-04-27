##
## THEME LOADING AND STORAGE
##

require 'fileutils'
require 'pathname'

module Crabgrass::Theme::Loader
 
  public

  def load
    start_time = Time.now

    # load and eval theme
    init_paths.each do |file|
      evaluate_theme_definition(file)
    end

    if @navigation.nil?
      @navigation = default_navigation
    end

    # in production, clear the cache once at startup.
    clear_cache if Rails.env == 'production'

    # create the theme's public directory and link the theme's
    # 'images' directory to it.
    ensure_dir(@public_directory)
    if @parent
      # mirror the parent theme's image directory
      mirror_directory_with_symlinks("#{@parent.directory}/images", "#{@directory}/images")
    end
    symlink("#{@directory}/images", "#{@public_directory}/images")

    info 'Loaded theme %s (%sms)' % [@directory, (Time.now - start_time)*1000]
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

  #
  # symlink, ensuring RELATIVE paths.
  #
  def symlink(src, dst)
    # these sanity checks are necessary to prevent Pathname from throwing
    # exceptions... Pathname does not act gracefully if it references bad symlinks
    # or missing files. 
    if !File.exists?(src)
      return    
    elsif File.symlink?(dst)
      FileUtils.rm(dst)
    elsif File.exists?(dst)
      raise 'For the theme to work, the file "%s" must not exist.' % dst
    end

    real_src_path = Pathname.new(src).realpath
    real_dst_dir  = Pathname.new(File.dirname(dst)).realpath

    relative_path = real_src_path.relative_path_from(real_dst_dir)
    FileUtils.ln_s(relative_path, real_dst_dir)
  end

  #
  # this method will fill a destination directory with symlinks to all the files
  # in a source directory. existing files in the destination directory are skipped.
  #
  def mirror_directory_with_symlinks(src, dst)
    return unless File.directory?(src)
    ensure_dir(dst)
    Dir.entries(src).each do |filename|
      next if filename == '.' or filename == '..'
      src_filename = File.join(src, filename)
      dst_filename = File.join(dst, filename)
      if File.symlink?(dst_filename) or !File.exist?(dst_filename)
        symlink(src_filename, dst_filename)
      end
    end
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

