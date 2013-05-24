##
## THEME LOADING AND STORAGE
##

require 'fileutils'
require 'pathname'

module Crabgrass::Theme::Loader

  ##
  ## CALLED BY THEME DEFINITION
  ##

  #
  #  step 0) theme.load
  #
  #  step 1)
  #    in theme.load():
  #      evaluate_ruby_file('init.rb')
  #
  #  step 2)
  #    in theme's init.rb:
  #      define_theme { ... }
  #    this calls loader.rb:
  #      def define_theme(&block)
  #      end
  #

  #
  # Parses the specified block and turns it into theme data.
  #
  # Called by the theme's init.rb.
  #
  def define_theme(args={}, &block)
    if args[:parent]
      @parent = Crabgrass::Theme[args[:parent]]
      if @parent.nil?
        puts "ERROR: no such parent theme '%s' available for theme '%s'" % [args[:parent], @name]
      else
        starting_data = @parent.data_copy
      end
    end
    starting_data ||= {}
    @data = Crabgrass::Theme::Options.parse(starting_data, &block)
  end

  #
  # Parses the specified block and turns it into navigation definition.
  # (or returns the existing navigation)
  #
  # Called by the theme's navigation.rb
  #
  def define_navigation(args={}, &block)
    if args[:parent]
      @navigation_parent = Crabgrass::Theme[args[:parent]]
      if @navigation_parent.nil?
        puts "ERROR: no such parent theme '%s' available for theme '%s'" % [args[:parent], @name]
      else
        starting_data = @navigation_parent.navigation
      end
    end
    starting_data ||= self.navigation
    @navigation = Crabgrass::Theme::NavigationDefinition.parse(self, starting_data, &block)
  end

  #
  # used in init.rb to define custom theme styles
  # DEPRECATED
  #
  def style(str)
    @style = str
  end

  ##
  ## PUBLIC METHODS
  ##

  public

  #
  # loads the data and navigation for this theme.
  #
  def load
    start_time = Time.now

    # load @data
    if data_path
      evaluate_ruby_file(data_path)
      # (the file pointed to by data_path must call 'define_theme')
    else
      define_theme(:parent => 'default')
    end

    # load @navigation
    if navigation_path
      evaluate_ruby_file(navigation_path)
      # (the file pointed to by navigation_path must call 'define_navigation')
    else
      define_navigation(:parent => 'default')
    end

    # in production, clear the cache once at startup.
    clear_cache if Rails.env == 'production'

    # create the theme's public directory and link the theme's
    # 'images' directory to it.
    ensure_dir(@public_directory)
    if @parent
      # mirror the parent theme's image directory
      mirror_directory_with_symlinks(@parent.directory + "images", @directory + "images")
    end
    symlink(@directory + "images", @public_directory + "images")

    info 'Loaded theme %s (%sms)' % [@directory, (Time.now - start_time)*1000]
  end

  def reload!
    if @parent
      @parent.reload!
    end
    @navigation = nil
    info 'Reloading theme %s' % @name
    load()
  end

  #
  # returns all the file paths that have theme definition data in them.
  #
  #def init_paths
  #  paths = []
  #  paths << @directory+'init.rb' if File.exist?(@directory+'init.rb')
  #  paths << @directory+'navigation.rb' if File.exist?(@directory+'navigation.rb')
  #  raise 'ERROR: no theme definition files in %s' % @directory unless paths.any?
  #  return paths
  #end

  def data_path
    @directory+'init.rb' if File.exist?(@directory+'init.rb')
  end

  def navigation_path
    @directory+'navigation.rb' if File.exist?(@directory+'navigation.rb')
  end

  #
  # includes ancestors
  #
  def all_data_paths
    if parent
      [data_path] + parent.all_data_paths
    else
      [data_path]
    end
  end

  #
  # includes ancestors
  #
  def all_navigation_paths
    if navigation_parent
      [navigation_path] + navigation_parent.all_navigation_paths
    else
      [navigation_path]
    end
  end

  private

  def self.create_and_load(theme_name)
    theme = Crabgrass::Theme.new( theme_name )
    theme.load
    theme
  end

  #
  # evals a file with the current binding
  #
  def evaluate_ruby_file(file)
    eval(IO.read(file), binding, file.to_s)
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

