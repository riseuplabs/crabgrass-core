SecureHeaders::Configuration.default do |config|
  config.cookies = {
    secure: true,
    httponly: true,
    samesite: {
      strict: true
    }
  }
  config.csp = {
    default_src: %w('self'),
    script_src: %w('self' 'unsafe-inline' 'unsafe-eval'),
    img_src: %w('self' *),
    media_src: ['*'],
    style_src: %w(* 'unsafe-inline')
  }
end
