module Fxer
  class Fetcher
    class Ecb
      class << self

        #
        # download fetches the most recent data from the ECB URL if
        # today's data isn't already present in the user's chosen
        # directory (otherwise it aborts).
        #
        # After downloading the ECB data, it checks if the data contains
        # data not yet accounted for in the directory (otherwise it aborts).
        #
        # Then it saves that data to a new XML file in the user's
        # chosen directory.
        #
        def download
          set_data_parameters

          return true if abort_if_current(Date.today.to_s)

          fetch_data

          return true if abort_if_current(@date)

          save_data
        end

        private

          #
          # set_data_parameters fetches and assigns the ECB URL from config.
          # And it assigns the user's chosen rate directory, falling back to
          # the working directory.
          #
          def set_data_parameters
            config_path = File.join(Fxer::FXER_CONFIGURATION_PATH, "ecb.yml")
            @url = YAML.load_file(config_path)[:ecb_fx_rate_url]
            @dir = ENV['FXER_RATE_DATA_DIRECTORY'] || Dir.pwd
          end

          #
          # save_data to an XML file named after the @date
          #
          def save_data
            @path = File.join(@dir, "#{@date.to_s}.xml")

            puts "\tData found. Saving data for '#{@date.to_s}' to '#{@path}' ..."
            open(@path, "wb") { |f| f.write(@data) }

            puts "\tSuccess!\n\n"
          end

          #
          # fetch_data from the URL, and fetch the file's
          # most recent date from that data
          #
          def fetch_data
            puts "\n\n\tGoing to fetch data from '#{@url}'"
            @data = open(@url) { |io| io.read }
            @date = Hash.from_xml(@data)["Envelope"]["Cube"]["Cube"].first["time"]
          end

          #
          # abort_if_current takes one argument:
          #   1. date - a string representing the date a file is named for,
          # and returns a boolean of that file's existence.
          #
          def abort_if_current(date)
            return false unless File.exist?(File.join(@dir, "#{date.to_s}.xml"))

            puts "\n\n\tThe most recent data already exists in #{@dir}. Exiting ...\n\n"
            true
          end
      end
    end

  end
end
