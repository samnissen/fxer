# Fxer

Fxer is an exchange rate calculator, using the European Central Bank's
rates covering the last 90 days.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fxer'
```

And then execute:

```bash
bundle
```

Or install it yourself as, replacing the version numbers:

```bash
gem build fxer.gemspec
gem install fxer-1.2.3.gem
```

## Usage

### Simplest exchange

Fxer includes a quick and simple way of obtaining an exchange rate via a
separate namespace:

```ruby
ExchangeRate.at(Date.today, 'EUR', 'AUD')
# => 1.4732
```

### Configurable exchange

For situations where you need more control, the Fxer namespace provides
configuration:

```ruby
exchanger = Fxer::Exchange.new.configure do |config|
  config.permissive = true
  config.source = :ecb
  config.store = "/my/path/"
end

exchanger.convert_at_date(Date.today, 'GBP', 'USD')
# => 1.309507859949982
```

#### `config.permissive`

Fxer by default uses the most recently available data at or before
the date indicated. Setting permissive to false changes that, in effect a
strict-mode, and an error will be raised if a date
doesn't have corresponding data.

#### `config.source`

Fxer is designed to accommodate code for additional sources
of exchange rate data. Source can only be `:ecb` as of now.

#### `config.store`

The configuration of store allows you to indicate where you have
locally stored your exchange data file, so that Fxer does not need
to download that data to determine the rate.

### Executable exchange

fxer also provides an executable for getting rates in Bash:

```bash
FXER_RATE_DATA_PATH="/my/path" fxer "2017-07-18" NOK HKD
# => 0.9689571804652662
```

where the environment variable for local file hosting is optional.

### Data retrieval (also executable)

And fxer will download new ECB data for you, in either Ruby or Bash:

```ruby
ENV['FXER_RATE_DATA_DIRECTORY'] = "/my/path/"
Fxer::Fetcher::Ecb.download
```

```bash
FXER_RATE_DATA_DIRECTORY="/my/path/" fxer-fetcher ecb
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `bundle exec rspec spec` to run the tests.
You can also run `bin/console` for an interactive prompt that
will allow you to experiment.

Until this is pushed to RubyGems and GitHub, there is no defined development
process.

## Contributing

Bug reports and pull requests will be welcome once fxer is live
at https://github.com/samnissen/fxer.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
