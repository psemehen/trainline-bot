# frozen_string_literal: true

require "spec_helper"
require_relative "../com_thetrainline"

RSpec.describe ComThetrainline do
  let(:from) { "Berlin Hbf" }
  let(:to) { "Warszawa-Centralna" }
  let(:departure_at) { "#<DateTime: 2025-03-12T14:00:00+00:00 ((2456774j,22140s,0n),+0s,2299161j)>" }

  describe ".find" do
    context "when valid data is provided" do
      context "when verifying the first journey" do
        let(:first_journey_details) do
          {
            departure_station: "Berlin Hbf",
            destination_station: "Warszawa-Centralna",
            duration_in_minutes: 307,
            changeovers: 1,
            service_agencies: ["Deutsche Bahn", "Other"]
          }
        end

        let(:first_fare) do
          {
            price_in_cents: 3526,
            currency_code: "GBP",
            comfort_class: 2,
            name: "1st class"
          }
        end

        it "returns the correct journey details" do
          VCR.use_cassette("ComThetrainline/journey_response") do
            result = ComThetrainline.find(from, to, departure_at)

            expect(result.first).to include(first_journey_details)
            expect(result.first[:fares].size).to eq(6)
            expect(result.first[:fares].first).to eq(first_fare)
          end
        end
      end
    end

    context "when data is missing" do
      context "when 'from' location is missing" do
        let(:from) { nil }
        let(:to) { nil }

        it "raises an error for missing 'from' location" do
          VCR.use_cassette("ComThetrainline/journey_response") do
            result = ComThetrainline.find(from, to, departure_at)

            expect(result[:message]).to eq("Validation errors.")
            expect(result[:errors]).to eq(["Missing 'from' location", "Missing 'to' location"])
          end
        end
      end
    end
  end
end
