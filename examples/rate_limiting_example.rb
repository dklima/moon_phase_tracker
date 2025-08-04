#!/usr/bin/env ruby
# frozen_string_literal: true

# Example demonstrating rate limiting functionality in MoonPhaseTracker
# This example shows different ways to configure and use rate limiting

require_relative "../lib/moon_phase_tracker"

puts "=== MoonPhaseTracker Rate Limiting Examples ==="
puts

puts "1. Default Rate Limiting (1 request/second):"
puts "=" * 50

tracker = MoonPhaseTracker::Tracker.new
puts "Rate limit configuration: #{tracker.rate_limit_info}"

start_time = Time.now
puts "Making first request..."
phases1 = tracker.phases_for_year(2025)
first_request_time = Time.now - start_time

puts "Making second request (should be rate limited)..."
phases2 = tracker.phases_for_year(2024)
total_time = Time.now - start_time

puts "First request took: #{first_request_time.round(2)}s"
puts "Total time for both requests: #{total_time.round(2)}s"
puts "Rate limiting delay: #{(total_time - first_request_time).round(2)}s"
puts

puts "2. Custom Rate Limiting (3 requests/second, burst size 2):"
puts "=" * 55

custom_rate_limiter = MoonPhaseTracker::RateLimiter.new(
  requests_per_second: 3.0,
  burst_size: 2
)

custom_tracker = MoonPhaseTracker::Tracker.new(rate_limiter: custom_rate_limiter)
puts "Rate limit configuration: #{custom_tracker.rate_limit_info}"

start_time = Time.now
puts "Making burst requests (should be immediate)..."
custom_tracker.phases_for_year(2025)
custom_tracker.phases_for_year(2024)
burst_time = Time.now - start_time

puts "Making third request (should be rate limited)..."
custom_tracker.phases_for_year(2023)
total_time = Time.now - start_time

puts "Burst requests (2) took: #{burst_time.round(2)}s"
puts "Total time for 3 requests: #{total_time.round(2)}s"
puts "Rate limiting delay for 3rd request: #{(total_time - burst_time).round(2)}s"
puts

puts "3. Environment Variable Configuration:"
puts "=" * 42

ENV["MOON_PHASE_RATE_LIMIT"] = "2.5"
ENV["MOON_PHASE_BURST_SIZE"] = "3"

env_tracker = MoonPhaseTracker::Tracker.new
puts "Rate limit configuration from ENV: #{env_tracker.rate_limit_info}"
puts

puts "4. Disabled Rate Limiting:"
puts "=" * 27

ENV["MOON_PHASE_RATE_LIMIT"] = "0"

disabled_tracker = MoonPhaseTracker::Tracker.new
puts "Rate limit configuration: #{disabled_tracker.rate_limit_info || 'DISABLED'}"

start_time = Time.now
puts "Making multiple requests without rate limiting..."
5.times do |i|
  disabled_tracker.phases_for_year(2025 - i)
end
total_time = Time.now - start_time

puts "5 requests took: #{total_time.round(2)}s (no rate limiting)"
puts

puts "5. Rate Limit Status Monitoring:"
puts "=" * 34

rate_limiter = MoonPhaseTracker::RateLimiter.new(
  requests_per_second: 1.0,
  burst_size: 2
)

puts "Initial status: #{rate_limiter.configuration}"
puts "Can proceed? #{rate_limiter.can_proceed?}"

puts "\nMaking first request..."
rate_limiter.throttle
puts "After 1st request: #{rate_limiter.configuration}"
puts "Can proceed? #{rate_limiter.can_proceed?}"

puts "\nMaking second request..."
rate_limiter.throttle
puts "After 2nd request: #{rate_limiter.configuration}"
puts "Can proceed? #{rate_limiter.can_proceed?}"

puts "\nWaiting for token replenishment..."
sleep(1.1)
puts "After waiting: #{rate_limiter.configuration}"
puts "Can proceed? #{rate_limiter.can_proceed?}"

puts
puts "=== Rate Limiting Examples Complete ==="

# Clean up environment variables
ENV.delete("MOON_PHASE_RATE_LIMIT")
ENV.delete("MOON_PHASE_BURST_SIZE")
