# frozen_string_literal: true

require "rspec"
require "webmock/rspec"
require "httparty"
require_relative "../../services/location_fetcher_service"
require_relative "../../errors/location_error"
require_relative "../../com_thetrainline"
require_relative "../../lib/redis_connection"

RSpec.describe LocationFetcherService do
  describe ".fetch_location_code" do
    let(:location) { "Berlin" }

    before do
      allow(RedisConnection.instance).to receive(:get).and_return(nil)
      allow(RedisConnection.instance).to receive(:set)
    end

    context "when the response is successful" do
      before do
        stub_request(:get, /#{ComThetrainline::BASE_URL}/o)
          .to_return(
            status: 200,
            body: '{"searchLocations":[{"code":"1234"}]}',
            headers: {"Content-Type" => "application/json"}
          )
      end

      it "returns the correct location code" do
        location_code = described_class.fetch_location_code(location)
        expect(location_code).to eq("1234")
      end
    end

    context "when the HTTP request fails" do
      context "when internal server error" do
        before do
          stub_request(:get, /#{ComThetrainline::BASE_URL}/o)
            .to_return(status: 500, body: "Internal Server Error")
        end

        it "raises a LocationError with the correct message" do
          expect {
            described_class.fetch_location_code(location)
          }.to raise_error(Errors::LocationError, /Failed to fetch location/)
        end
      end

      context "when timeout error" do
        before do
          allow(HTTParty).to receive(:get).and_raise(Timeout::Error)
        end

        it "raises a LocationError with the correct message" do
          expect {
            described_class.fetch_location_code(location)
          }.to raise_error(Errors::LocationError, /due to network or timeout issues/)
        end
      end
    end

    context "when the location data is invalid or missing" do
      before do
        stub_request(:get, /#{ComThetrainline::BASE_URL}/o)
          .to_return(
            status: 200,
            body: '{"searchLocations":[{"code":""}]}',
            headers: {"Content-Type" => "application/json"}
          )
      end

      it "raises a LocationError with the correct message" do
        expect {
          described_class.fetch_location_code(location)
        }.to raise_error(Errors::LocationError, /Invalid location data received/)
      end
    end

    context "when location data is cached" do
      before do
        allow(RedisConnection.instance).to receive(:get).with("location_code:#{location}").and_return("1234")
      end

      it "returns the cached location code" do
        location_code = described_class.fetch_location_code(location)
        expect(location_code).to eq("1234")
      end
    end

    context "when location data is not in cache" do
      it "fetches location code and stores it in cache" do
        stub_request(:get, /#{ComThetrainline::BASE_URL}/o)
          .to_return(
            status: 200,
            body: '{"searchLocations":[{"code":"1234"}]}',
            headers: {"Content-Type" => "application/json"}
          )

        location_code = described_class.fetch_location_code(location)
        expect(location_code).to eq("1234")

        expect(RedisConnection.instance).to have_received(:set).with("location_code:#{location}", "1234", ex: 86_400)
      end
    end
  end
end
