# Meataxe

Meataxe is a killer collection of Capistrano 3 deployment scripts.

## Installation

Add this line to your application's Gemfile:

```
gem 'meataxe', group: :development
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install meataxe
```

## Usage


Add the following lines to your `Capfile`

```ruby
    require 'capistrano/puma'
    require 'capistrano/puma/workers' # if you want to control the workers (in cluster mode)
    require 'capistrano/puma/jungle'  # if you need the jungle tasks
    require 'capistrano/puma/monit'   # if you need the monit tasks
    require 'capistrano/puma/nginx'   # if you want to upload a nginx site template
```

Then you can use ```cap -T``` to list available tasks
