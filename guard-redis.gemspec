# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'guard/redis/version'

Gem::Specification.new do |s|
  s.name        = 'guard-redis'
  s.version     = Guard::RedisVersion::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Zachery Moneypenny']
  s.email       = ['guard-redis@whazzing.com']
  s.homepage    = 'http://rubygems.org/gems/guard-redis'
  s.summary     = 'Guard gem for Redis'
  s.description = 'Guard::Redis automatically starts and restarts your local redis server.'

  s.required_rubygems_version = '>= 1.3.6'

  s.add_dependency 'rake'
  s.add_dependency 'guard',        '~> 2.8'
  s.add_dependency 'guard-compat', '~> 1.2'
  s.add_dependency 'redis',        '~> 2.2'

  s.add_development_dependency 'bundler',  '>= 1.7'
  s.add_development_dependency 'rspec',    '~> 3.1'

  s.files        = Dir.glob('{lib}/**/*') + %w[LICENSE README.md]
  s.require_path = 'lib'
end
