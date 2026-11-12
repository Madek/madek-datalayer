source 'https://rubygems.org'

gem 'rails', '~> 8.1.4.1'
# security floors (Dependabot / OSV 2026-11)
# Note: do not pin rack here — consumers need either 2.2.25+ or 3.2.8+ (sinatra);
# Bundler forbids declaring rack again after eval_gemfile.
gem 'nokogiri', '>= 1.19.5'
gem 'crass', '>= 1.0.8'
# json 3 breaks sprockets 3 / execjs 2.10.1 / faraday_middleware 0.14 (create_additions / arity)
# lower bound kept from webapp's previous security floor
gem 'json', '>= 2.15.2.1', '< 3'
# multi_json 1.15 breaks zencoder under json 2/3 option APIs; keep a recent multi_json
gem 'multi_json', '>= 1.16'
gem 'pg'
gem 'pg_tasks', git: 'https://github.com/leihs/rails_pg-tasks', branch: 'rails8'

gem 'textacular', '~> 5.0'

gem 'base32-crockford'
gem 'bcrypt', '~> 3.1.22'
gem 'chronic_duration'
gem 'listen'
gem 'liquid'
# https://stackoverflow.com/questions/71191685/visit-psych-nodes-alias-unknown-alias-default-psychbadalias
gem 'psych', '< 4'
gem 'rspec-rails', '~> 7', group: [:test, :development]
gem 'strong_password'
gem 'uuidtools'
gem 'zencoder', '~> 2.4'

gem 'factory_bot', group: [:test, :development]
gem 'faker', group: [:test, :development] # There is a bug in 3.1.0 (as per 30.12.2022)
gem 'pry', group: [:test, :development]
gem 'pry-nav', group: [:test, :development]
gem 'pry-rails', group: [:test, :development]
gem 'webmock', group: [:test]

# fix: the version that rails requires vanished, force newer version. see <https://github.com/rails/rails/issues/41750>
gem 'mimemagic'
