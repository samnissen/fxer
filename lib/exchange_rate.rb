require "fxer"

#
# ExchangeRate is a convenience module with one method to pass through
# data to Fxer::Exchange.
#
# Names like "ExchangeRate", "Exchange", etc. are the names of existing gems.
# Also, while Fxer::Exchange has options and state, ExchangeRate is
# simple and stateless. See that class for options and other details.
#
module ExchangeRate

  #
  # at requires three arguments, a date, and two strings representing
  # currencies. More details about the requirements are detailed in
  # Exchange.
  #
  # Example:
  #   ExchangeRate.at(Date.today,'GBP','USD')
  #
  def self.at(date, base, counter)
    Fxer::Exchange.new.convert_at_date(date, base, counter)
  end
end
