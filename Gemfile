source "http://rubygems.org"

# Specify your gem's dependencies in guard-rspec.gemspec
gemspec

gem 'rake'

require 'rbconfig'

platforms :ruby do
  if RbConfig::CONFIG['target_os'] =~ /darwin/i
    gem 'rb-fsevent', '>= 0.3.9'
    gem 'growl',      '~> 1.0.3'
  end
  if RbConfig::CONFIG['target_os'] =~ /linux/i
    gem 'rb-inotify', '>= 0.5.1'
    gem 'libnotify',  '~> 0.1.3'
  end
end

platforms :jruby do
  if RbConfig::CONFIG['target_os'] =~ /darwin/i
    gem 'growl',      '~> 1.0.3'
  end
  if RbConfig::CONFIG['target_os'] =~ /linux/i
    gem 'rb-inotify', '>= 0.5.1'
    gem 'libnotify',  '~> 0.1.3'
  end
end

group :test do
  gem 'rspec'
  gem 'guard-rspec'
end