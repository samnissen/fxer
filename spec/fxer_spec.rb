require "spec_helper"

INVALID_SOURCE_REGEX = /\APlease provide one of these valid source keys: \[.{0,}\].\z/
DATE_ERROR_REGEX = /\A#{Regexp.quote(Fxer::Exchange::DATE_ERROR_MESSAGE)} [0-9]{4}-[0-9]{2}-[0-9]{2}\z/

TEST_DOWNLOAD_DIRECTORY = File.join(File.expand_path(__dir__), "support/", "downloads/")

TEST_STATIC_DIRECTORY = File.join(File.expand_path(__dir__), "support/", "static/")
TEST_ECB_STATIC_FX_DATA_PATH = File.join(TEST_STATIC_DIRECTORY, "eurofxref-hist-90d.xml")
TEST_STATIC_GBP_USD_RATE_19 = 0.173249703
TEST_STATIC_GBP_USD_RATE_21 = 101.73440464233903

RSpec.describe Fxer do
  let(:exchanger) { Fxer::Exchange.new }

  it "has a version number" do
    expect(Fxer::VERSION).not_to be nil
  end

  it "converts currency given a date and two valid currency symbols" do
    expect(exchanger.convert_at_date(Date.today,'GBP','USD')).to be_kind_of(Float)
    expect(exchanger.convert_at_date(Date.today,'DKK','BRL')).to be_kind_of(Float)
    expect(exchanger.convert_at_date(Date.today,'CAD','NOK')).to be_kind_of(Float)
  end

  it "converts currency using the simple convenience class" do
    expect(ExchangeRate.at(Date.today,'EUR','AUD')).to be_kind_of(Float)
  end

  it "does not return a Float given invalid country data" do
    expect{ exchanger.convert_at_date(Date.today,'GBP','') }.to raise_error("undefined method `rate' for nil:NilClass")
    expect{ exchanger.convert_at_date(Date.today,'','ABC') }.to raise_error("undefined method `rate' for nil:NilClass")
    expect{ exchanger.convert_at_date(Date.today,nil,123) }.to raise_error("undefined method `rate' for nil:NilClass")
  end

  # technicaly a configuration, too, but only to keep the result float stable.
  it "converts currency given a string representing a date and two valid currency symbols" do
    opts = { :store => TEST_ECB_STATIC_FX_DATA_PATH }
    local_data_exchanger = Fxer::Exchange.new(opts)
    date = "2017-07-19"

    result = local_data_exchanger.convert_at_date(date,'GBP','USD')
    expect(result).to eq(TEST_STATIC_GBP_USD_RATE_19)
  end

  context "when configuring fxer" do
    it "converts currency given ECB flag through #configure" do
      local_data_exchanger = Fxer::Exchange.new.configure do |config|
        config.source = :ecb
      end

      result = local_data_exchanger.convert_at_date(Date.today,'GBP','USD')
      expect(result).to be_kind_of(Float)
    end

    it "converts currency given ECB flag through `.new(opts)`" do
      opts = { :source => :ecb }
      local_data_exchanger = Fxer::Exchange.new(opts)

      result = local_data_exchanger.convert_at_date(Date.today,'GBP','USD')
      expect(result).to be_kind_of(Float)
    end

    it "does not convert currency given an unknown flag" do
      opts = { :source => :xyz }

      expect{
        Fxer::Exchange.new(opts)
      }.to raise_error(RuntimeError, INVALID_SOURCE_REGEX)
    end

    it "converts currency to the next available date" do
      local_data_exchanger = Fxer::Exchange.new.configure do |config|
        config.source = :ecb
        config.store = TEST_ECB_STATIC_FX_DATA_PATH
      end

      date = Date.strptime("2017-07-16")
      result = local_data_exchanger.convert_at_date(date,'GBP','USD')
      expect(result).to be_kind_of(Float)
    end

    it "does not convert currency to the date if permissive is set to false" do
      local_data_exchanger = Fxer::Exchange.new.configure do |config|
        config.source = :ecb
        config.store = TEST_ECB_STATIC_FX_DATA_PATH
        config.permissive = false
      end

      date = Date.strptime("2017-07-16")
      expect{
        local_data_exchanger.convert_at_date(date,'GBP','USD')
      }.to raise_error(RuntimeError, DATE_ERROR_REGEX)
    end

    it "converts currency with locally stored data" do
      opts = { :store => TEST_ECB_STATIC_FX_DATA_PATH }
      local_data_exchanger = Fxer::Exchange.new(opts)
      date = Date.strptime("2017-07-21")

      result = local_data_exchanger.convert_at_date(date,'GBP','USD')
      expect(result).to eq(TEST_STATIC_GBP_USD_RATE_21)
    end
  end

  context "when executing the app from the command line" do
    it "converts currency" do
      exe_path = File.expand_path("../exe/fxer", __dir__)
      date = "2017-07-19"

      output = `FXER_RATE_DATA_PATH=#{TEST_ECB_STATIC_FX_DATA_PATH} ruby -Ilib #{exe_path} #{date} GBP USD`
      result = output.split("\n").last

      expect(Float(result)).to eq(TEST_STATIC_GBP_USD_RATE_19)
    end

    it "downloads currency data" do
      xml_path = File.join(TEST_DOWNLOAD_DIRECTORY, "*.xml")
      Dir.glob(xml_path).each { |f| File.delete(f) }
      fail("Unable to clear test data downloads directory") unless Dir[xml_path].empty?

      exe_path = File.expand_path("../exe/fxer-fetcher", __dir__)
      o = `FXER_RATE_DATA_DIRECTORY=#{TEST_DOWNLOAD_DIRECTORY} ruby -Ilib #{exe_path} ecb`

      fail("An error occurred: #{o}") unless $?.success?

      expect(Dir[xml_path].size).to eq(1)
      expect(File.read(Dir.glob(xml_path).first).empty?).to be(false)
      expect(Nokogiri::XML(File.read(Dir.glob(xml_path).first)).errors.empty?).to be(true)

      Dir.glob(xml_path).each { |f| File.delete(f) }
    end

    it "only downloads currency data when the data is new" do
      xml_path = File.join(TEST_DOWNLOAD_DIRECTORY, "*.xml")
      Dir.glob(xml_path).each { |f| File.delete(f) }
      fail("Unable to clear test data downloads directory") unless Dir[xml_path].empty?

      exe_path = File.expand_path("../exe/fxer-fetcher", __dir__)
      o = `FXER_RATE_DATA_DIRECTORY=#{TEST_DOWNLOAD_DIRECTORY} ruby -Ilib #{exe_path} ecb`
      fail("An error occurred: #{o}") unless $?.success?
      f1_time = File.mtime(Dir[TEST_DOWNLOAD_DIRECTORY + "*.xml"].first)

      o = `FXER_RATE_DATA_DIRECTORY=#{TEST_DOWNLOAD_DIRECTORY} ruby -Ilib #{exe_path} ecb`
      fail("An error occurred: #{o}") unless $?.success?
      f2_time = File.mtime(Dir[TEST_DOWNLOAD_DIRECTORY + "*.xml"].first)

      expect(f1_time).to eq(f2_time)
      expect(Dir[xml_path].size).to eq(1)

      Dir.glob(xml_path).each { |f| File.delete(f) }
    end
  end
end
