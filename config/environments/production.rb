require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Assume all access to the app is happening through a SSL-terminating reverse
  # proxy (the Kamal/kamal-proxy TLS terminator, or a PaaS load balancer).
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :solid_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  # Solid Queue uses the primary database connection (single-database setup).
  config.active_job.queue_adapter = :solid_queue

  # Host used by links generated in mailer templates (password reset, invites).
  # Railway sets RAILWAY_PUBLIC_DOMAIN automatically, so the free *.up.railway.app
  # subdomain works with no manual config; APP_HOST overrides it for a real domain.
  app_host = ENV["APP_HOST"].presence || ENV["RAILWAY_PUBLIC_DOMAIN"].presence || "localhost"
  config.action_mailer.default_url_options = { host: app_host, protocol: "https" }
  config.action_controller.default_url_options = { host: app_host, protocol: "https" }

  # Real email delivery via any SMTP provider (Postmark / SendGrid / Resend / SES
  # / Mailgun). Stays inert until SMTP_ADDRESS is set, so a no-email beta still
  # boots cleanly. Remember to add SPF/DKIM/DMARC DNS records for the domain.
  if ENV["SMTP_ADDRESS"].present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.smtp_settings = {
      address: ENV["SMTP_ADDRESS"],
      port: ENV.fetch("SMTP_PORT", 587).to_i,
      user_name: ENV["SMTP_USER_NAME"],
      password: ENV["SMTP_PASSWORD"],
      domain: ENV.fetch("SMTP_DOMAIN", app_host),
      authentication: :plain,
      enable_starttls_auto: true
    }
  else
    # No provider configured yet: don't blow up a background job if mail is sent.
    config.action_mailer.raise_delivery_errors = false
  end

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks. Locked to the
  # app's domain (APP_HOST and/or Railway's public domain) when known; left open
  # otherwise so a first boot without the vars configured isn't locked out.
  allowed_hosts = [ ENV["APP_HOST"], ENV["RAILWAY_PUBLIC_DOMAIN"] ].compact_blank
  if allowed_hosts.any?
    allowed_hosts.each do |host|
      config.hosts << host
      config.hosts << ".#{host}" # subdomains (e.g. www.)
    end
    config.hosts << ".railway.app" if ENV["RAILWAY_PUBLIC_DOMAIN"].present? # internal routing/health
    # Skip DNS rebinding protection for the default health check endpoint.
    config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
  end
end
