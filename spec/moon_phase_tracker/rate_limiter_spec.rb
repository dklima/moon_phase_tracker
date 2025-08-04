# frozen_string_literal: true

require "spec_helper"

RSpec.describe MoonPhaseTracker::RateLimiter do
  let(:rate_limiter) { described_class.new(requests_per_second: 2.0, burst_size: 3) }

  describe "#initialize" do
    it "sets default rate limit from environment variable", :aggregate_failures do
      ENV["MOON_PHASE_RATE_LIMIT"] = "0.5"
      ENV["MOON_PHASE_BURST_SIZE"] = "2"

      limiter = described_class.new
      config = limiter.configuration

      expect(config[:requests_per_second]).to eq(0.5)
      expect(config[:burst_size]).to eq(2)
    end

    it "uses constructor parameters over environment variables", :aggregate_failures do
      ENV["MOON_PHASE_RATE_LIMIT"] = "0.5"
      ENV["MOON_PHASE_BURST_SIZE"] = "2"

      limiter = described_class.new(requests_per_second: 3.0, burst_size: 5)
      config = limiter.configuration

      expect(config[:requests_per_second]).to eq(3.0)
      expect(config[:burst_size]).to eq(5)
    end

    it "uses default values when no parameters or environment variables", :aggregate_failures do
      ENV.delete("MOON_PHASE_RATE_LIMIT")
      ENV.delete("MOON_PHASE_BURST_SIZE")

      limiter = described_class.new
      config = limiter.configuration

      expect(config[:requests_per_second]).to eq(1.0)
      expect(config[:burst_size]).to eq(1)
    end

    it "raises error for invalid rate limit" do
      expect { described_class.new(requests_per_second: "invalid") }.to raise_error(ArgumentError)
    end

    it "raises error for invalid burst size" do
      expect { described_class.new(burst_size: "invalid") }.to raise_error(ArgumentError)
    end
  end

  describe "#throttle" do
    it "allows immediate requests up to burst size", :aggregate_failures do
      start_time = Time.now

      # Should allow burst_size requests immediately
      3.times { rate_limiter.throttle }

      elapsed = Time.now - start_time
      expect(elapsed).to be < 0.1
    end

    it "enforces rate limiting after burst is exhausted" do
      # Exhaust the burst
      3.times { rate_limiter.throttle }

      start_time = Time.now
      rate_limiter.throttle
      elapsed = Time.now - start_time

      # With 2.0 requests per second, should wait ~0.5 seconds
      expect(elapsed).to be >= 0.4
      expect(elapsed).to be < 0.7
    end
  end

  describe "#can_proceed?" do
    it "returns true when tokens are available" do
      expect(rate_limiter.can_proceed?).to be true
    end

    it "returns false when no tokens are available" do
      # Exhaust the burst
      3.times { rate_limiter.throttle }

      expect(rate_limiter.can_proceed?).to be false
    end

    it "returns true after tokens are replenished" do
      # Exhaust the burst
      3.times { rate_limiter.throttle }

      # Wait for token replenishment
      sleep(0.6)

      expect(rate_limiter.can_proceed?).to be true
    end
  end

  describe "#configuration" do
    it "returns current configuration", :aggregate_failures do
      config = rate_limiter.configuration

      expect(config[:requests_per_second]).to eq(2.0)
      expect(config[:burst_size]).to eq(3)
      expect(config[:available_tokens]).to be_a(Integer)
    end

    it "shows available tokens decreasing after requests", :aggregate_failures do
      initial_tokens = rate_limiter.configuration[:available_tokens]
      rate_limiter.throttle
      current_tokens = rate_limiter.configuration[:available_tokens]

      expect(current_tokens).to be < initial_tokens
    end
  end

  describe "thread safety" do
    it "handles concurrent requests safely" do
      threads = []
      results = []
      mutex = Mutex.new

      # Create multiple threads making requests
      5.times do
        threads << Thread.new do
          start_time = Time.now
          rate_limiter.throttle
          elapsed = Time.now - start_time

          mutex.synchronize { results << elapsed }
        end
      end

      threads.each(&:join)

      # Should have some requests that were delayed
      delayed_requests = results.count { |time| time > 0.1 }
      expect(delayed_requests).to be > 0
    end
  end

  describe "token bucket algorithm" do
    let(:slow_limiter) { described_class.new(requests_per_second: 1.0, burst_size: 1) }

    it "replenishes tokens over time" do
      # Use up the token
      slow_limiter.throttle
      expect(slow_limiter.can_proceed?).to be false

      # Wait for replenishment
      sleep(1.1)
      expect(slow_limiter.can_proceed?).to be true
    end

    it "caps tokens at burst size" do
      # Wait longer than needed to fill burst
      sleep(2.0)

      config = slow_limiter.configuration
      expect(config[:available_tokens]).to eq(1) # Should not exceed burst_size
    end
  end

  after do
    # Clean up environment variables
    ENV.delete("MOON_PHASE_RATE_LIMIT")
    ENV.delete("MOON_PHASE_BURST_SIZE")
  end
end
