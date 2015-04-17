GradeCraft::Application.configure do
 #  config.action_controller.perform_caching = false
 #  config.action_dispatch.best_standards_support = :builtin
 #  config.action_mailer.default_url_options = { :host => 'gradecraft:3000' }
 #  config.action_mailer.delivery_method = :test
 #  config.action_mailer.perform_deliveries = true
 #  config.action_mailer.raise_delivery_errors = true
 #  config.active_support.deprecation = :log
 #  # config.assets.compress = false # handle below
 #  config.assets.debug = true
 #  # config.cache_classes = false
 #  config.cache_store = :null_store
 #  # config.consider_all_requests_local = true
 #  config.eager_load = false
 #  config.session_store :cookie_store, key: '_gradecraft_session', :expire_after => 60.minutes
 #  config.active_record.mass_assignment_sanitizer = :strict
 #  config.consider_all_requests_local = false
 #
 #  # production asset parameters
 #  config.assets.compile = false
 #  config.assets.precompile += %w( vendor/modernizr.js )
 #  config.assets.compress = true
 #  config.assets.css_compressor = :sass
 #  config.assets.digest = true
 #  config.assets.js_compressor = :uglifier
 #  config.cache_classes = true
 #
 #  # config.assets.js_compressor = Uglifier.new(mangle: false) if defined? Uglifier
 #  #
  #
  config.action_controller.default_url_options = { :host => 'gradecraft.com' }
  config.action_controller.perform_caching = true
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'
  config.action_mailer.default_url_options = { :host => 'gradecraft.com' }
  config.action_mailer.delivery_method = :smtp
#  config.action_mailer.smtp_settings = {
#    :authentication => :plain,
#    :address => 'smtp.mandrillapp.com',
#    :port => 587,
#    :domain => 'gradecraft.com',
#    :user_name => ENV['MANDRILL_USERNAME'],
#    :password => ENV['MANDRILL_PASSWORD']
#  }
  config.active_support.deprecation = :notify
  config.assets.compile = false
  config.assets.precompile += %w( vendor/modernizr.js )
  config.assets.compress = true
  config.assets.css_compressor = :sass
  config.assets.digest = true
  config.assets.js_compressor = :uglifier
  config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
  config.assets.precompile += %w( .svg .eot .woff .ttf )
  config.cache_classes = true
  # config.cache_store = :dalli_store, ENV['MEMCACHED_URL'], { :namespace => 'gradecraft_production', :expires_in => 1.day, :compress => true }
  config.consider_all_requests_local = false
  config.eager_load = true
  config.i18n.fallbacks = true
  config.log_formatter = ::Logger::Formatter.new
  config.log_level = :info
  config.serve_static_files = false
  config.session_store ActionDispatch::Session::CacheStore, :expire_after => 60.minutes
end
  #
end

CarrierWave.configure do |config|
  config.storage = :file
end

