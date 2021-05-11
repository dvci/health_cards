# Health Cards

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'health_cards'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install health_cards

## Development

After checking out the repo, run `bin/setup` or `bundle install` to install dependencies. 
Then, run `rake test` to run the tests. 
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Linting

```shell
be rubocop -c .rubocop.yml
```
[Rubocop will automatically traverse up the parent tree](https://github.com/rubocop/rubocop/issues/536) and 
find the `.rubocop.yml` and try to require `rubocop-rails` if `-c .rubocop.yml` is not employed