require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DecidimAws
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    config.time_zone = "Europe/Paris"
    config.i18n.load_path += Dir[Rails.root.join('config/locales/**/*.yml').to_s]

    Decidim.unconfirmed_access_for = 0.days

    # config.after_initialize do
    #   config.session_store :active_record_store, :key => '_decidim_session'
    # end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    #
    if Rails.application.secrets.dig(:asset, :host).present?
      config.action_mailer.asset_host = Rails.application.secrets.dig(:asset, :host)
    end

    initializer "cookie store", after: "Expire sessions" do
      Rails.application.config.session_store :cookie_store, :key => '_decidim_session', expire_after: Decidim.config.expire_session_after
    end
  end
end
