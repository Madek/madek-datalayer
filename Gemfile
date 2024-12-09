source 'https://rubygems.org'

gem 'rails', '~> 7.2.0'
gem "sprockets", "<4" # DO NOT UPGRADE SPROCKETS!

gem 'pg'

# gem 'pg_tasks', git: 'https://github.com/leihs/rails_pg-tasks'
# gem 'pg_tasks', path: '/Users/uvanbinsloc/dev/leihs-misc/rails_pg-tasks'
gem 'pg_tasks', git: 'https://github.com/leihs/rails_pg-tasks', branch: 'rails7'

gem 'textacular', '~> 5.0'

gem 'base32-crockford'
gem 'bcrypt', '~> 3.1.13'
gem 'chronic_duration'
# https://stackoverflow.com/questions/71191685/visit-psych-nodes-alias-unknown-alias-default-psychbadalias
gem 'listen'
gem 'liquid'
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
