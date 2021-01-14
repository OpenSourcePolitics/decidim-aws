# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", git: "https://github.com/OpenSourcePolitics/decidim.git", branch: "alt/petition-0.24.0.dev"
# gem "decidim-consultations", git: "https://github.com/OpenSourcePolitics/decidim.git", branch: "alt/petition-0.24.0.dev"
gem "decidim-initiatives", git: "https://github.com/OpenSourcePolitics/decidim.git", branch: "alt/petition-0.24.0.dev"

# gem "decidim", path: "../decidim"
# gem "decidim-consultations", path: "../decidim"
# gem "decidim-initiatives", path: "../decidim"

gem "decidim-term_customizer", git: "https://github.com/OpenSourcePolitics/decidim-module-term_customizer.git", branch: "0.dev"

# gem "omniauth-decidim", git: "https://github.com/OpenSourcePolitics/decidim.git"
# gem "decidim-omniauth_extras", git: "https://github.com/OpenSourcePolitics/decidim.git"
# gem "decidim-initiatives_extras", git: "https://github.com/OpenSourcePolitics/decidim.git"

# gem "omniauth-decidim", path: "../omniauth-decidim"
# gem "decidim-omniauth_extras", path: "../decidim-module-omniauth_extras"
# gem "decidim-initiatives_extras", path: "../decidim-module-initiatives_extras"

# gem "decidim-blazer", path: "../decidim-module-blazer"

gem "bootsnap", "~> 1.4"

gem "puma", ">= 4.3.5"
gem "uglifier", "~> 4.1"

gem "faker", "~> 2.14"

# Avoid wicked_pdf require error
gem "wicked_pdf"
gem "wkhtmltopdf-binary"

gem 'activerecord-session_store'

gem "rack-oauth2", "~> 1.16"
gem "omniauth-oauth2", "1.7.0"
gem "omniauth_openid_connect", "0.3.1"
# gem "omniauth-saml", "~> 1.10"

gem 'rubyzip', require: 'zip'

gem "dotenv-rails", "~> 2.7"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  # Use latest simplecov from master until next version of simplecov is
  # released (greather than 0.18.5)
  # See https://github.com/decidim/decidim/issues/6230
  gem "simplecov", "~> 0.19.0"

  gem "decidim-dev", git: "https://github.com/OpenSourcePolitics/decidim.git", branch: "alt/petition-0.24.0.dev"
  # gem "decidim-dev", path: "../decidim"
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
  # Profiling gems
  gem "bullet"
  gem "flamegraph"
  gem "memory_profiler"
  gem "rack-mini-profiler", require: false
  gem "stackprof"
end

group :production do
  gem "sentry-raven"
  gem "sidekiq"
  gem "sidekiq-scheduler"
  gem "fog-aws"
  gem "dalli-elasticache"
  gem "newrelic_rpm"
end
