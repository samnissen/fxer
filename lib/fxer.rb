require "exchange_rate"
require "fxer/exchange"
require "fxer/fetcher"
require "fxer/version"

module Fxer
  FXER_BASE_PATH = Pathname(__dir__).parent
  FXER_CONFIGURATION_PATH = File.join(FXER_BASE_PATH, "config")
end
