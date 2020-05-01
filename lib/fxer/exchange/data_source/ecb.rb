module Fxer
  class Exchange
    class DataSource
      class Ecb
        attr_reader :rate_set

        #
        # initialize takes one optional hash.
        # Arguments are defined in Fxer::Exchange.
        #
        # It assigns store to be used in the Ecb class. initialize also
        # kicks off the request for data and normalization into our
        # Data objects.
        #
        def initialize(opts = {})
          @store = opts[:store]
          @options = opts.except(:store)

          fetch_rates
          normalize_rates
        end

        private

          #
          # normalize_rates creates a Data object to store each Date, which
          # itself stores n Currencies, all assigned to @rate_set
          #
          # In ECB data, the Euro is static, and so is omitted from the dataset.
          # So, the Currency representing the Euro is manually added.
          #
          def normalize_rates
            @rate_set = Fxer::Exchange::Data.new(@options)

            @raw_data.each do |rate_sets|
              date = Fxer::Exchange::Data::Date.new()
              date.date = Date.strptime(rate_sets["time"], "%Y-%m-%d")

              date.currencies = rate_sets["Cube"].map do |rate|
                currency = Fxer::Exchange::Data::Date::Currency.new()
                currency.key = rate["currency"]
                currency.rate = rate["rate"]
                currency
              end
              date.currencies << european_currency

              @rate_set.dates << date
            end
          end

          #
          # european_currency creates the Euro currency object, and
          # returns that static currency object.
          #
          # Since it is always the base of the ECB currency data,
          # the Euro is always set to 1.
          #
          def european_currency
            currency = Fxer::Exchange::Data::Date::Currency.new()
            currency.key = "EUR"
            currency.rate = 1
            currency
          end

          #
          # fetch_rates gathers the entire available data set. (For ECB,
          # that's 90 days worth of exchange rate data.)
          # First, fetch_rates tries to gather the data from file,
          # then directly from the source URL when it cannot.
          #
          def fetch_rates
            @raw_data   = local_data
            @raw_data ||= from_url
          end

          #
          # from_url opens the ECB XML feed, converts to hash, and
          # returns a Hash representing the relevant portion.
          #
          def from_url
            hashify(open(config[:ecb_fx_rate_url]))
          end

          #
          # local_data accesses the provided data file, converts to hash and
          # returns a Hash representing the relevant portion, but
          # only if one is indeed provided.
          #
          def local_data
            return false unless @store && File.exists?(@store)

            return hashify(File.open(@store))
          end

          #
          # hashify converts uses activesupport to convert XML to hash,
          # then accesses and returns a Hash representing the relevant portion.
          #
          def hashify(raw)
            Hash.from_xml(raw)["Envelope"]["Cube"]["Cube"]
          end

          #
          # config accesses the yaml file containing the
          # default Ecb configuration.
          #
          def config
            @config_path = File.join(FXER_CONFIGURATION_PATH, "ecb.yml")
            @config ||= YAML.load_file(@config_path)
          end
      end
    end
  end
end
