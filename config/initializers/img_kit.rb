IMGKit.configure do |config|
  config.wkhtmltoimage = '/app/bin/wkhtmltoimage' if Rails.env.production?
end
