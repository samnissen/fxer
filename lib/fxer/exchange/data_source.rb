require "active_support/core_ext/hash"
require "date"
require "open-uri"
require "pathname"

require "fxer/exchange/data_source/ecb"

module Fxer
  class Exchange
    class DataSource

      #
      # initialize accepts one optional argument,
      #   1. a hash of options which will be passed to whichever data source
      #      the user has indicated (i.e. Fxer::Exchange::DataSource::Ecb).
      #
      def initialize(opts = {})
        @options = opts
      end

      #
      # exchange takes 4 required arguments and returns the data required
      # to determine an exchange value. Arguments are defined in Fxer::Exchange.
      #
      def exchange(date, base, counter, source)
        fetch_rates(source).at(date).from(base).to(counter).rates
      end

      private

        #
        # fetch_rates takes one argument,
        #   1. a symbol represnting a source's corresponding class name.
        #      Source symbols are defined in Fxer::Exchange.
        #
        # fetch_rates converts the source of data indicated by the user,
        # i.e. :ecb, (which has been sanitized during configuration), and
        # converts that to a subclass of DataSource, providing options
        # and returning a set of rates, represented by an
        # Fxer::Exchange::Data object.
        #
        def fetch_rates(source)
          klass_name = "#{source}".downcase.capitalize
          Object.const_get("Fxer::Exchange::DataSource::#{klass_name}").new(@options).rate_set
        end
    end
  end
end
