if Rails.env != 'production'
  if Dir.glob(STATIC_JS_DEST_DIR + '/*.js').any?
    puts "You can't run in development mode with files in #{STATIC_JS_DEST_DIR}"
    puts 'Run rake cg:clean_assets'
    exit
  end
end
