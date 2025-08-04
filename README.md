# MoonPhaseTracker 🌙

A Ruby gem for tracking moon phases using the official US Naval Observatory (USNO) API. Perfect for creating lunar calendar-based scheduling applications.

**Expected accuracy: ~85-90% (suitable for lunar calendars)**

## Features

- 🌑 Query moon phases by month, year, or from a specific date
- 🌒 Complete 8-phase lunar cycle support (4 major + 4 intermediate phases)
- 🌓 Simple and intuitive interface  
- 🌔 Accurate data from the official USNO Navy API
- 🌕 Visual representation with moon phase emojis
- 🌖 Interpolated intermediate phases for enhanced precision
- 🌗 Visual indicators for calculated vs official phases
- 🌘 Automatic caching to optimize requests
- ⚡ Robust error handling
- 🚦 Configurable rate limiting to respect API limits

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'moon_phase_tracker'
```

And then execute:

```bash
bundle install
```

Or install it directly:

```bash
gem install moon_phase_tracker
```

## Usage

### Basic Usage (4 Major Phases)

```ruby
require 'moon_phase_tracker'

# Moon phases for August 2025 (4 major phases only)
phases = MoonPhaseTracker.phases_for_month(2025, 8)
puts phases.first.to_s
# => "🌑 New Moon - 2025-08-04 at 11:13"

# All phases for 2025
year_phases = MoonPhaseTracker.phases_for_year(2025)

# Next 6 phases from a specific date
future_phases = MoonPhaseTracker.phases_from_date("2025-08-01", 6)
```

### Complete 8-Phase Lunar Cycle

```ruby
require 'moon_phase_tracker'

# All 8 phases for August 2025 (major + intermediate)
all_phases = MoonPhaseTracker.all_phases_for_month(2025, 8)
all_phases.each do |phase|
  indicator = phase.interpolated ? "~ " : "  "
  puts "#{indicator}#{phase}"
end
# =>   🌑 New Moon - 2025-08-04 at 11:13
# => ~ 🌒 Waxing Crescent - 2025-08-08 at 03:16
# =>   🌓 First Quarter - 2025-08-12 at 15:19
# => ~ 🌔 Waxing Gibbous - 2025-08-15 at 16:53
# =>   🌕 Full Moon - 2025-08-19 at 18:26
# => ~ 🌖 Waning Gibbous - 2025-08-22 at 13:56 
# =>   🌗 Last Quarter - 2025-08-26 at 09:26
# => ~ 🌘 Waning Crescent - 2025-08-29 at 02:56

# All 8 phases for entire year
all_year_phases = MoonPhaseTracker.all_phases_for_year(2025)

# All 8 phases from specific date (2 lunar cycles)
extended_phases = MoonPhaseTracker.all_phases_from_date("2025-08-01", 2)
```

### Using the Tracker Class

```ruby
tracker = MoonPhaseTracker::Tracker.new

# Automatic formatting for display
august_phases = tracker.phases_for_month(2025, 8)
formatted = tracker.format_phases(august_phases, "August Phases")
puts formatted

# Next moon phase
next_phase = tracker.next_phase
puts next_phase.to_s

# Current month phases
current_month = tracker.current_month_phases
```

### Working with Individual Phases

```ruby
phase = phases.first

# Phase information
puts phase.name          # "New Moon"
puts phase.symbol        # "🌑"
puts phase.formatted_date # "2025-08-04"
puts phase.formatted_time # "11:13"
puts phase.interpolated   # false (official USNO data)

# Working with interpolated phases
interpolated_phase = all_phases.find(&:interpolated)
puts interpolated_phase.interpolated  # true (calculated)
puts interpolated_phase.name         # "Waxing Crescent"
puts interpolated_phase.symbol       # "🌒"

# Complete hash with all data
details = phase.to_h
# => {
#   name: "New Moon",
#   phase_type: :new_moon,
#   date: "2025-08-04",
#   time: "11:13",
#   symbol: "🌑",
#   iso_date: "2025-08-04",
#   utc_time: "2025-08-04T11:13:00Z",
#   interpolated: false
# }

# Date checks
phase.in_month?(2025, 8)  # => true
phase.in_year?(2025)      # => true
```

### Error Handling

```ruby
begin
  phases = MoonPhaseTracker.phases_for_month(2025, 8)
rescue MoonPhaseTracker::NetworkError => e
  puts "Network error: #{e.message}"
rescue MoonPhaseTracker::APIError => e
  puts "API error: #{e.message}"
rescue MoonPhaseTracker::InvalidDateError => e
  puts "Invalid date: #{e.message}"
end
```

### Practical Examples

See the `examples/usage_example.rb` and `examples/eight_phases_example.rb` files for complete usage examples.

## API Reference

### Main Methods (4 Major Phases)

- `MoonPhaseTracker.phases_for_month(year, month)` - Major phases for a specific month
- `MoonPhaseTracker.phases_for_year(year)` - All major phases for a year
- `MoonPhaseTracker.phases_from_date(date, num_phases)` - Major phases from a specific date

### 8-Phase Methods (Major + Intermediate)

- `MoonPhaseTracker.all_phases_for_month(year, month)` - All 8 phases for a specific month
- `MoonPhaseTracker.all_phases_for_year(year)` - All 8 phases for a year
- `MoonPhaseTracker.all_phases_from_date(date, num_cycles)` - All 8 phases from a specific date

### Complete Phase Types

#### Major Phases (Official USNO Data)
- 🌑 `:new_moon` - New Moon
- 🌓 `:first_quarter` - First Quarter
- 🌕 `:full_moon` - Full Moon
- 🌗 `:last_quarter` - Last Quarter

#### Intermediate Phases (Interpolated ~85-90% accuracy)
- 🌒 `:waxing_crescent` - Waxing Crescent 
- 🌔 `:waxing_gibbous` - Waxing Gibbous
- 🌖 `:waning_gibbous` - Waning Gibbous
- 🌘 `:waning_crescent` - Waning Crescent

## Data Source

This gem uses the official US Naval Observatory (USNO) API:
- **Base URL**: https://aa.usno.navy.mil/api/moon/phases/
- **API Version**: 4.0.1
- **Documentation**: https://aa.usno.navy.mil/data/api

All times are provided in Universal Time (UTC).

## Rate Limiting

The gem implements respectful rate limiting to avoid overwhelming the USNO Navy API. By default, it allows **1 request per second** with a burst size of 1.

### Default Rate Limiting

```ruby
# Default: 1 request per second
tracker = MoonPhaseTracker::Tracker.new

# Check current rate limit configuration
puts tracker.rate_limit_info
# => {:requests_per_second=>1.0, :burst_size=>1, :available_tokens=>1}

# Multiple requests will be automatically rate limited
start = Time.now
tracker.phases_for_year(2025)  # Immediate
tracker.phases_for_year(2024)  # Waits ~1 second
puts "Total time: #{Time.now - start}s"  # ~1.0 seconds
```

### Custom Rate Limiting

```ruby
# Create custom rate limiter: 3 requests per second, burst of 2
rate_limiter = MoonPhaseTracker::RateLimiter.new(
  requests_per_second: 3.0,
  burst_size: 2
)

tracker = MoonPhaseTracker::Tracker.new(rate_limiter: rate_limiter)

# Burst requests are immediate, then rate limited
tracker.phases_for_year(2025)  # Immediate
tracker.phases_for_year(2024)  # Immediate (burst)
tracker.phases_for_year(2023)  # Waits ~0.33 seconds
```

### Environment Variable Configuration

```ruby
# Set via environment variables
ENV["MOON_PHASE_RATE_LIMIT"] = "2.5"
ENV["MOON_PHASE_BURST_SIZE"] = "3"

tracker = MoonPhaseTracker::Tracker.new
puts tracker.rate_limit_info
# => {:requests_per_second=>2.5, :burst_size=>3, :available_tokens=>3}
```

### Disabling Rate Limiting

```ruby
# Disable rate limiting completely
ENV["MOON_PHASE_RATE_LIMIT"] = "0"

tracker = MoonPhaseTracker::Tracker.new
puts tracker.rate_limit_info  # => nil

# Or pass nil explicitly
tracker = MoonPhaseTracker::Tracker.new(rate_limiter: nil)
```

### Rate Limit Monitoring

```ruby
rate_limiter = MoonPhaseTracker::RateLimiter.new(
  requests_per_second: 1.0,
  burst_size: 2
)

# Check if request can proceed without waiting
puts rate_limiter.can_proceed?  # => true

# Check current token status
puts rate_limiter.configuration
# => {:requests_per_second=>1.0, :burst_size=>2, :available_tokens=>2}

# Manual rate limiting control
rate_limiter.throttle  # Waits if necessary and consumes token
```

### Token Bucket Algorithm

The rate limiter uses a token bucket algorithm:

- **Tokens**: Represent available requests
- **Bucket Size**: Maximum burst requests allowed
- **Refill Rate**: How quickly tokens are replenished
- **Thread Safe**: Handles concurrent requests safely

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dklima/moon_phase_tracker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/dklima/moon_phase_tracker/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MoonPhaseTracker project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/dklima/moon_phase_tracker/blob/main/CODE_OF_CONDUCT.md).
