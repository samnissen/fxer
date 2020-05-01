module Fxer
  class Exchange

    INVALID_SOURCE_MESSAGE = "Please provide one of these valid source keys:"

    class ExchangeConfiguration
      attr_accessor :source, :store, :permissive

      #
      # This configuration object allows for hash, block or object setting
      # of configuration options.
      #
      # initialize sets the default source and protects the app from attempting
      # to use invalid source keys.
      #
      def initialize
        set_defaults
      end

      #
      # In order to ensure that a key passed at any arbitrary point is valid
      # the setter is overwritten to validate the key.
      #
      def source=(key)
        @source = validate_source_key(key)
      end

      private

        #
        # set_defaults does what is says on the tin, setting source and store
        # to their default values.
        #
        # Note that a nil value for the store path will bypass the functions
        # that access locally stored data.
        #
        def set_defaults
          @source       = config[:default_source_key]
          @store        = config[:default_store_path]
          @permissive   = config[:default_permission]
        end

        #
        # config accesses the yaml file containing the default configuration,
        # and returns a Hash of its values.
        #
        def config
          @config_path ||= File.join(FXER_CONFIGURATION_PATH, "fxer.yml")
          @config ||= YAML.load_file(@config_path)[:exchange]
        end


        #
        # validate_source_key takes an argument
        #   1. key, a symbol representing
        # and returns the key if it is within the array of valid keys
        #
        # This stops any request that specifies a key that that is not
        # encoded in our application as a valid bank data source.
        #
        def validate_source_key(key)
          unless config[:valid_source_keys].include?(key)
            raise "#{INVALID_SOURCE_MESSAGE} #{config[:valid_source_keys]}."
          end

          key
        end
    end
  end
end
