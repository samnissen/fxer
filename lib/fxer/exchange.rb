require "fxer/exchange/data"
require "fxer/exchange/data_source"
require "fxer/exchange/exchange_configuration"

require "yaml"
require "bigdecimal"

module Fxer
  class Exchange
    attr_writer :configuration

    #
    # initialize takes a hash of optional values:
    #   1. :source - a symbol representing the source of the exchange data
    #   2. :store  - a string representing a directory where
    #      exchange data is stored, so that new data is not
    #      downloaded upon each exchange calculation.
    #   3. :permissive - a boolean that, set to true, allows the exchange
    #      rate to be pulled from the nearest possible date. Set to false,
    #      an error will arise if no data exists for the date.
    #
    # Alternatively these same values can be provided through
    # a configuraiton block, like so:
    #   exchanger = Fxer::Exchange.new.configure do |config|
    #     config.source = :ecb
    #     config.store = "/path/to/data"
    #   end
    #
    # Alternatively these same values can be provided directly
    #   exchanger = Fxer::Exchange.new
    #   exchanger.configuration.source = :ecb
    #   exchanger.configuration.store = "/path/to/data"
    #
    # And these values can be reset to their defaults,
    # defined in config/fxer.yml.
    #
    # Guidance on setting up much of the configuration comes from:
    # http://brandonhilkert.com/blog/ruby-gem-configuration-patterns/
    #
    def initialize(opts = {})
      configure { |config|
        config.source = opts[:source] if opts[:source]
        config.store  = opts[:store]  if opts[:store]
        config.permissive  = opts[:permissive]  if opts[:permissive]
      }
    end

    def configuration
      @configuration ||= ExchangeConfiguration.new
    end
    def reset
      @configuration = ExchangeConfiguration.new
    end
    def configure
      yield(configuration)
      self
    end

    #
    # convert_at_date takes these arguments:
    #   1. date - A Date object for the day's rates to access.
    #      The closest available day will be accessed if the
    #      chosen day is not available, or date is otherwise invalid
    #   2. base - Representing a country's currency,
    #      formatted per source requirements
    #   3. counter - Same format as `base`
    #
    # and returns a float, the result of diving two floats
    # representing the currency's relative value at the date specified.
    #
    # Example:
    #   opts = {
    #     :store => "/my/path/",
    #     :source => :ecb,
    #     :permissive => true
    #   }
    #   Fxer::Exchange.new(opts).convert_at_date(Date.today, "HKD", "NZD")
    # => 1.12345
    #
    def convert_at_date(date, base, counter)
      data_source = Fxer::Exchange::DataSource.new(options)
      counter_rate, base_rate = data_source.exchange(date, base, counter, source)

      Float(BigDecimal(counter_rate.rate.to_s) / BigDecimal(base_rate.rate.to_s))
    end

    private

      #
      # DataSource and its subclasses don't require the same level of
      # convenient configuration -- so they get a Hash of options
      # (instead of a ExchangeConfiguration object, for instance).
      # options returns such a Hash.
      #
      def options
        {
          :store => @configuration.store,
          :permissive => @configuration.permissive
        }
      end

      #
      # source is a convenience method for the configuration object's source,
      # and it returns a Symbol.
      #
      def source
        @configuration.source
      end
  end
end
