source :rubygems

gem 'rake', '0.8.7'
gem 'rails', '2.3.5'
gem 'gettext', '2.1.0'
gem 'gettext_rails', '2.1.0'
gem 'rmagick', '2.13.1'
gem 'RedCloth', '4.2.2'
gem 'will_paginate', '2.3.12'
gem 'ruby-feedparser', '0.7'
gem 'ferret', '0.11.6'
gem 'daemons', '1.0.10'
gem 'mongrel', '1.1.5'
gem 'mongrel_cluster', '1.0.5'
gem 'hpricot', '0.8.2'
gem 'i18n', '0.4.1'

gem 'sqlite3-ruby', '1.2.4'
gem 'pg', '0.8.0'

group :test do
  gem 'cucumber', '0.4.0'
  gem 'webrat', '0.5.1'
  gem 'rspec', '1.2.9'
  gem 'rspec-rails', '1.2.9'
  gem 'Selenium', '>= 1.1.14'
  gem 'selenium-client', '>= 1.2.17'
  gem 'database_cleaner'
  gem 'exception_notification', '1.0.20090728'
  gem 'system_timer'
  gem 'tidy'
  gem 'mocha'
  gem 'rcov'
end

def program(name)
  unless system("which #{name} > /dev/null")
    puts "W: Program #{name} is needed, but was not found in your PATH"
  end
end

program 'java'
program 'firefox'

