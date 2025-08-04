# MoonPhaseTracker 🌙

A Ruby gem for tracking moon phases using the official US Naval Observatory (USNO) API. Perfect for creating lunar calendar-based scheduling applications.

## Features

- 🌑 Query moon phases by month, year, or from a specific date
- 🌓 Simple and intuitive interface
- 🌕 Accurate data from the official USNO Navy API
- 🌗 Visual representation with moon phase emojis
- ⚡ Automatic caching to optimize requests
- 🛡️ Robust error handling

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

### Basic Usage

```ruby
require 'moon_phase_tracker'

# Moon phases for August 2025
phases = MoonPhaseTracker.phases_for_month(2025, 8)
puts phases.first.to_s
# => "🌑 New Moon - 2025-08-04 at 11:13"

# All phases for 2025
year_phases = MoonPhaseTracker.phases_for_year(2025)

# Next 6 phases from a specific date
future_phases = MoonPhaseTracker.phases_from_date("2025-08-01", 6)
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

# Complete hash with all data
details = phase.to_h
# => {
#   name: "New Moon",
#   phase_type: :new_moon,
#   date: "2025-08-04",
#   time: "11:13",
#   symbol: "🌑",
#   iso_date: "2025-08-04",
#   utc_time: "2025-08-04T11:13:00Z"
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

See the `examples/usage_example.rb` file for complete usage examples.

## API Reference

### Main Methods

- `MoonPhaseTracker.phases_for_month(year, month)` - Phases for a specific month
- `MoonPhaseTracker.phases_for_year(year)` - All phases for a year
- `MoonPhaseTracker.phases_from_date(date, num_phases)` - Phases from a specific date

### Phase Types

- 🌑 `:new_moon` - New Moon
- 🌓 `:first_quarter` - First Quarter
- 🌕 `:full_moon` - Full Moon
- 🌗 `:last_quarter` - Last Quarter

## Data Source

This gem uses the official US Naval Observatory (USNO) API:
- **Base URL**: https://aa.usno.navy.mil/api/moon/phases/
- **API Version**: 4.0.1
- **Documentation**: https://aa.usno.navy.mil/data/api

All times are provided in Universal Time (UTC).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dklima/moon_phase_tracker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/dklima/moon_phase_tracker/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MoonPhaseTracker project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/dklima/moon_phase_tracker/blob/main/CODE_OF_CONDUCT.md).
