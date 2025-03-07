# frozen_string_literal: true

require "rspec"
require "webmock/rspec"
require "httparty"
require_relative "../../services/journeys_fetcher_service"
require_relative "../../errors/journey_error"
require_relative "../../com_thetrainline"

RSpec.describe JourneysFetcherService do
  describe ".fetch_journeys" do
    let(:departure_code) { "trainline:generic:loc:7000" }
    let(:destination_code) { "trainline:generic:loc:8000" }
    let(:departure_at) { "2025-03-12T09:00:00" }
    let(:url) { "#{ComThetrainline::BASE_URL}/api/journey-search/" }

    context "when the response is successful" do
      before do
        stub_request(:post, url)
          .to_return(
            status: 200,
            body: '{"journeys": [{"id": "journey-1", "departure": "2025-03-12T09:00:00"}]}',
            headers: {"Content-Type" => "application/json"}
          )
      end

      it "returns the parsed journey data" do
        result = described_class.fetch_journeys(departure_code, destination_code, departure_at)
        expect(result).to eq("journeys" => [{"id" => "journey-1", "departure" => "2025-03-12T09:00:00"}])
      end
    end

    context "when the HTTP request fails" do
      before do
        stub_request(:post, url)
          .to_return(status: 500, body: "Internal Server Error")
      end

      it "raises a JourneyError with the correct message" do
        expect {
          described_class.fetch_journeys(departure_code, destination_code, departure_at)
        }.to raise_error(Errors::JourneyError, /Failed to fetch journeys/)
      end
    end

    context "when the response body cannot be parsed as JSON" do
      before do
        stub_request(:post, url)
          .to_return(
            status: 200,
            body: "Invalid JSON response",
            headers: {"Content-Type" => "application/json"}
          )
      end

      it "raises a JourneyError with the correct message" do
        expect {
          described_class.fetch_journeys(departure_code, destination_code, departure_at)
        }.to raise_error(Errors::JourneyError, /Error parsing journey data/)
      end
    end

    context "when an exception is raised during the request" do
      before do
        allow(HTTParty).to receive(:post).and_raise(Timeout::Error)
      end

      it "raises a JourneyError with the exception details" do
        expect {
          described_class.fetch_journeys(departure_code, destination_code, departure_at)
        }.to raise_error(Errors::JourneyError, /Error fetching journeys from/)
      end
    end
  end
end
