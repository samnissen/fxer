require "fxer/exchange/data/date/currency"

module Fxer
  class Exchange
    class Data

      #
      # Fxer::Exchange::Data::Date must be namespaced or
      # it will overwrite the existing Date class, resulting in warnings:
      # "warning: toplevel constant Date referenced by X", and odd behavior.
      # http://stem.ps/rails/2015/01/25/ruby-gotcha-toplevel-constant-referenced-by.html
      #
      class Fxer::Exchange::Data::Date
        attr_accessor :currencies, :date

        #
        # In creating a date, create a shell to store this Date's currencies.
        #
        def initialize
          @currencies = []
        end

        #
        # Setting the date allows string or Date object. For more details,
        # see the documentation for normalize_date.
        #
        def date=(raw_date)
          @date = Date.normalize_date(raw_date)
        end

        #
        # self.normalize_date takes one argument,
        #   1. raw_date, either a string represnting a date, or a Date,
        #      where the former will be converted into the latter
        # and returns a Date object if it is a convertable string.
        # Note this is used elsewhere, hence the Eigenclass method.
        #
        # In normalize_date, casing the class of a ruby object is not done
        # by `.class`ing the object because of how the === operator works:
        # https://stackoverflow.com/a/3801609/1651458
        #
        # Also, `::Date` is required because of the local Date
        # class in this Gem: https://stackoverflow.com/a/29351635/1651458
        #
        def self.normalize_date(raw_date)
          case raw_date
          when String
            ::Date.strptime(raw_date) # A namespace that specifies Ruby's core class.
          else
            raw_date
          end
        end
      end
    end
  end
end
