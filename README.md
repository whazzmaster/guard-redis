# Guard::Redis [![Build Status](https://secure.travis-ci.org/whazzmaster/guard-redis.png)](http://travis-ci.org/whazzmaster/guard-redis)

Redis guard manages your development [Redis](http://redis.io) server, and will automatically restart if necessary.

The code for this gem was taken from [this blog post by Avdi Grimm](http://avdi.org/devblog/2011/06/15/a-guardfile-for-redis/).  It refers to [this Gist](https://gist.github.com/1026546), and I searched around for an existing repo quite a bit before packing it up here.  __All credit goes to Avdi for the source__ and all fault goes to me for configuration or packaging issues.

## Install

Make sure you have [Guard](https://github.com/guard/guard) installed before continuing.

Install the gem:

    $ gem install guard-redis

Add it to your Gemfile.  You should really only need it in development and test environments; this gem is not meant to manage production server instances of Redis.

    gem 'guard-redis'

Add the guard definition to your Guardfile by running:

    $ guard init redis

## Options

The main purpose of Guard::Redis is to ensure that redis-server is running while you're coding and testing. It can optionally monitor a set of files and reload the process (useful if you're frequently changing code that affects items in Redis).

It takes several options related to its configuration.

### List of available options
~~~~ruby
:executable => "/path/to/redis/server/executable"  # Set the custom path to the Redis server executable
:port => 9999                                      # Set a custom port number the Redis server is running on
:pidfile => "/var/pid/redis.pid"                   # Set a custom path the where the pidfile is written
:reload_on_change => false                         # Reload Redis if any of the specified files change. Note that you
                                                   # must specify this option in addition to passing a block to Guard.
~~~~

## Contributers

https://github.com/whazzmaster/guard-redis/graphs/contributors
