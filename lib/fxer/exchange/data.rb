require "fxer/exchange/data/date"

module Fxer
  class Exchange

    DATE_ERROR_MESSAGE = "Unable to find your date:"

    class Data
      attr_accessor :dates, :transaction_date, :to, :from

      #
      # initalize instantiates dates as an array to contain its Date objects.
      #
      def initialize(opts = {})
        @options = opts
        @dates = []
      end

      #
      # rates sifts the available data for the nearest date, then
      # sifts through the currencies to find the base and counter rates.
      #
      # Note @transaction_date, @to, @from must be set before `rates`
      # is called. Convenient methods exist for this purpose. For instance:
      #   rate_set = Fxer::Exchange::DataSource::Ecb.new(options).rate_sets
      #   rates = rate_set.at("2017-07-21").from("USD").to("GBP").rates
      #
      # rates returns an array of two Currency objects,
      # [counter, base].
      #
      def rates
        date = nearest_date

        [
          date.currencies.find{ |d| d.key == @to },
          date.currencies.find{ |d| d.key == @from }
        ]
      end

      #
      # at, from and to are convenience methods to set the transaction date,
      # base currency, and counter currency, respectively. They return self
      # so that they can be chained. arguments are defined in Fxer::Exchange
      #
      def at(d)
        @transaction_date = d
        self
      end
      def from(f)
        @from = f
        self
      end
      def to(t)
        @to = t
        self
      end

      #
      # transaction_date takes one argument, defined in Fxer::Exchange
      # and normalizes it to a Date object
      #
      def transaction_date=(raw_date)
        @transaction_date = Date.normalize_date(d)
      end

      private

        #
        # nearest_date chooses the date object matching the transaction date.
        #
        # If no date is matched, the next date can be chosen if the
        # permissive flag evaluates to true. Otherwise it raises an error.
        #
        def nearest_date
          d = @dates.find { |d| "#{d.date}" == "#{@transaction_date}" }
          return d if d

          raise "#{DATE_ERROR_MESSAGE} #{@transaction_date}" unless @options[:permissive]

          dates.sort_by{ |d| d.date }.reverse.first
        end
    end
  end
end
