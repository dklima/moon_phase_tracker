# frozen_string_literal: true

require "spec_helper"
require "webmock/rspec"

RSpec.describe MoonPhaseTracker::Client, "rate limiting integration" do
  let(:sample_response) do
    {
      "phasedata" => [
        {
          "phase" => "New Moon",
          "year" => 2025,
          "month" => 8,
          "day" => 4,
          "time" => "11:13"
        }
      ]
    }
  end

  before do
    WebMock.stub_request(:get, /aa\.usno\.navy\.mil/)
           .to_return(status: 200, body: sample_response.to_json, headers: { "Content-Type" => "application/json" })
  end

  describe "default rate limiting" do
    let(:client) { described_class.new }

    it "enables rate limiting by default", :aggregate_failures do
      rate_info = client.rate_limit_info

      expect(rate_info).not_to be_nil
      expect(rate_info[:requests_per_second]).to eq(1.0)
      expect(rate_info[:burst_size]).to eq(1)
    end

    it "enforces rate limiting on consecutive requests" do
      start_time = Time.now

      # First request should be immediate
      client.phases_for_year(2025)
      first_request_time = Time.now - start_time

      # Second request should be delayed
      client.phases_for_year(2025)
      total_time = Time.now - start_time

      expect(first_request_time).to be < 0.1
      expect(total_time).to be >= 0.9 # Should wait ~1 second for second request
    end
  end

  describe "custom rate limiting" do
    let(:rate_limiter) { MoonPhaseTracker::RateLimiter.new(requests_per_second: 3.0, burst_size: 2) }
    let(:client) { described_class.new(rate_limiter: rate_limiter) }

    it "uses custom rate limiter configuration", :aggregate_failures do
      rate_info = client.rate_limit_info

      expect(rate_info[:requests_per_second]).to eq(3.0)
      expect(rate_info[:burst_size]).to eq(2)
    end

    it "allows burst requests without delay", :aggregate_failures do
      start_time = Time.now

      # Should allow 2 requests in burst
      client.phases_for_year(2025)
      client.phases_for_year(2024)

      elapsed = Time.now - start_time
      expect(elapsed).to be < 0.1
    end

    it "enforces rate limiting after burst is exhausted" do
      # Exhaust burst
      client.phases_for_year(2025)
      client.phases_for_year(2024)

      start_time = Time.now
      client.phases_for_year(2023)
      elapsed = Time.now - start_time

      # With 3.0 requests per second, should wait ~0.33 seconds
      expect(elapsed).to be >= 0.2
      expect(elapsed).to be < 0.5
    end
  end

  describe "disabled rate limiting" do
    before do
      ENV["MOON_PHASE_RATE_LIMIT"] = "0"
    end

    after do
      ENV.delete("MOON_PHASE_RATE_LIMIT")
    end

    let(:client) { described_class.new }

    it "disables rate limiting when configured to 0", :aggregate_failures do
      rate_info = client.rate_limit_info

      expect(rate_info).to be_nil
    end

    it "allows unlimited requests without delay" do
      start_time = Time.now

      # Multiple requests should be immediate
      5.times { client.phases_for_year(2025) }

      elapsed = Time.now - start_time
      expect(elapsed).to be < 0.5
    end
  end

  describe "environment variable configuration" do
    before do
      ENV["MOON_PHASE_RATE_LIMIT"] = "2.5"
      ENV["MOON_PHASE_BURST_SIZE"] = "3"
    end

    after do
      ENV.delete("MOON_PHASE_RATE_LIMIT")
      ENV.delete("MOON_PHASE_BURST_SIZE")
    end

    let(:client) { described_class.new }

    it "respects environment variable configuration", :aggregate_failures do
      rate_info = client.rate_limit_info

      expect(rate_info[:requests_per_second]).to eq(2.5)
      expect(rate_info[:burst_size]).to eq(3)
    end
  end

  describe "rate limiting with different request types" do
    let(:rate_limiter) { MoonPhaseTracker::RateLimiter.new(requests_per_second: 2.0, burst_size: 1) }
    let(:client) { described_class.new(rate_limiter: rate_limiter) }

    it "applies rate limiting to phases_from_date", :aggregate_failures do
      start_time = Time.now

      client.phases_from_date("2025-08-01", 1)
      client.phases_from_date("2025-08-02", 1)

      elapsed = Time.now - start_time
      expect(elapsed).to be >= 0.4 # Should wait ~0.5 seconds for second request
    end

    it "applies rate limiting across different request methods", :aggregate_failures do
      start_time = Time.now

      client.phases_for_year(2025)
      client.phases_from_date("2025-08-01", 1)

      elapsed = Time.now - start_time
      expect(elapsed).to be >= 0.4 # Rate limiting should apply across methods
    end
  end
end
