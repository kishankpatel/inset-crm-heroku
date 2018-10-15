require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'
require 'microsoft_graph/base'
require 'microsoft_graph/collection'
require 'microsoft_graph'
# require 'pdfkit'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module SalesCafe
  class Application < Rails::Application
    config.exceptions_app = self.routes
    config.exceptions_app = lambda do |env|
      ErrorsController.action(:render_error).call(env)
    end

    require Rails.root.join('lib', 'email_tracker', 'rack')
    # Some other stuff
    config.middleware.use EmailTracker::Rack
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/app/sweepers)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
    config.active_record.observers = :activity_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = false

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
	# config.middleware.use "PDFKit::Middleware", :print_media_type => true
	
	# config.action_mailer.delivery_method = :smtp
    # ActionMailer::Base.smtp_settings = {
    #     :address => "smtp.gmail.com",
    #     :port    => 587,
    #     :domain  => "gmail.com",
    #     :user_name  => "Okfinemb@gmail.com",
    #     :password   => "FuckY0u97",
    #     :authentication => :plain,
    #     :enable_starttls_auto => true
    #   } 
    config.action_mailer.delivery_method = :smtp
    # config.action_mailer.smtp_settings = { 
    # ActionMailer::Base.smtp_settings = {
    #   :address              => "smtp.sendgrid.net",
    #   :enable_starttls_auto => true,
    #   :port                 => 587 ,  #SSL is 465, and the port for TLS is 587
    #   :domain               => "insetcrm.com",
    #   :authentication       => 'plain',
    #    :user_name            => "YXBpa2V5", # "mbDHqY3mRj2Vz9m1qNkyXg",
    #   :password             => "U0cuYlVkcGxwT0VTWE9naGVFc3kzRzNzUS5xYThOQW5JcTBheE0tYTJKenI3Q0NM bktBY1hzV201QUN3VngxN213VzJF",
    #     }
    ActionMailer::Base.smtp_settings = {
      :address              => "smtp.sendgrid.net",
      :enable_starttls_auto => true,
      :port                 => 2525 ,  #SSL is 465, and the port for TLS is 587
      :domain               => "insetcrm.com",
      :authentication       => :plain,
      :user_name            => "Insethub", 
      :password             => "Ch@ngeS00n"
        }
    config.paperclip_defaults = { s3_host_name: "s3-us-east-2.amazonaws.com" }
  end
end

