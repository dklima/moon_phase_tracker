# frozen_string_literal: true

require "thread"

module MoonPhaseTracker
  # Rate limiter implementation using token bucket algorithm
  # Provides configurable rate limiting for API requests
  class RateLimiter
    DEFAULT_REQUESTS_PER_SECOND = 1.0
    DEFAULT_BURST_SIZE = 1

    def initialize(requests_per_second: nil, burst_size: nil)
      @requests_per_second = parse_rate_limit(requests_per_second)
      @burst_size = parse_burst_size(burst_size)
      @tokens = @burst_size.to_f
      @last_refill = current_time
      @mutex = Mutex.new
    end

    # Wait if necessary and then allow the request to proceed
    def throttle
      @mutex.synchronize do
        refill_tokens
        
        if @tokens >= 1.0
          consume_token
          return
        end

        wait_time = calculate_wait_time
        sleep(wait_time) if wait_time > 0

        refill_tokens
        consume_token
      end
    end

    def can_proceed?
      @mutex.synchronize do
        refill_tokens
        @tokens >= 1.0
      end
    end

    def configuration
      {
        requests_per_second: @requests_per_second,
        burst_size: @burst_size,
        available_tokens: @tokens.floor
      }
    end

    private

    def parse_rate_limit(rate)
      rate = rate || ENV.fetch("MOON_PHASE_RATE_LIMIT", DEFAULT_REQUESTS_PER_SECOND)
      
      case rate
      when String
        Float(rate)
      when Numeric
        rate.to_f
      else
        raise ArgumentError, "Rate limit must be a number"
      end
    end

    def parse_burst_size(size)
      size = size || ENV.fetch("MOON_PHASE_BURST_SIZE", DEFAULT_BURST_SIZE)
      
      case size
      when String
        Integer(size)
      when Numeric
        size.to_i
      else
        raise ArgumentError, "Burst size must be an integer"
      end
    end

    def refill_tokens
      now = current_time
      elapsed = now - @last_refill
      tokens_to_add = elapsed * @requests_per_second

      @tokens = [@tokens + tokens_to_add, @burst_size].min
      @last_refill = now
    end

    def calculate_wait_time
      return 0 if @tokens >= 1.0

      tokens_needed = 1.0 - @tokens
      tokens_needed / @requests_per_second
    end

    def consume_token
      @tokens = [@tokens - 1.0, 0.0].max
    end

    def current_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end