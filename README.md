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
    require 'meataxe/capistrano'
```

Then you can use ```cap -T``` to list available tasks.
