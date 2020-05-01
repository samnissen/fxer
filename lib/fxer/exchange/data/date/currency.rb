module Fxer
  class Exchange
    class Data
      class Date
        class Currency
          attr_accessor :key, :rate

          #
          # rate= takes one argument,
          #   1. raw_rate, a string representing a float
          # and converts it into a float, and assigns it to its rate attribute
          #
          def rate=(raw_rate)
            @rate = "#{raw_rate}".to_f
          end
        end
      end
    end
  end
end
