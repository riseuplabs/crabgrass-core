#
# compiles the ./app/asset/javascripts for deployment
#
# this should NOT be run in a development environment, because it
# will make it so that the javascripts don't update when you change them.
#
# In other words, when running in development mode, make sure that
# ./public/static is empty
#

begin

  require "fileutils"
  require "rubygems"
  require "sprockets"
  require "jsmin"
  require "./config/directories"

  def clean_dir(dir)
    Dir.glob(dir + '/*').each do |filename|
      File.unlink(filename) if File.exists?(filename) && !File.directory?(filename)
    end
  end

  def render_dir(from, to)
    environment = Sprockets::Environment.new
    environment.append_path from
    FileUtils.mkdir_p(to)
    input_files = Dir.glob(from + '/*.js')
    input_files.each do |file|
      filename = to + '/' + File.basename(file)
      File.open(filename, 'w') do |f|
        f.write(JSMin.minify(environment[file].to_s))
      end
      if `which gzip`.any?
        `gzip --stdout #{filename} > #{filename}.gz`
      end
    end
  end

  namespace :cg do
    desc "compile the javascript for deployment"
    task :compile_assets => :clean_assets do
      render_dir(STATIC_JS_SRC_DIR, STATIC_JS_DEST_DIR)
      render_dir(AS_NEEDED_JS_SRC_DIR, AS_NEEDED_JS_DEST_DIR)
    end

    desc "remove the compiled static assets"
    task :clean_assets do
      clean_dir(AS_NEEDED_JS_DEST_DIR)
      clean_dir(STATIC_JS_DEST_DIR)
    end
  end

rescue LoadError => exc
  # silently skip this rake task
end
