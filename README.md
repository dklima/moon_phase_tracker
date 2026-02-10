# 🌙 MoonPhaseTracker - Your Cosmic Calendar Companion

*"Because every developer deserves to howl at the right moon."*

Ever wondered when to deploy your code for maximum lunar luck? Or perhaps you need to schedule that midnight debugging session during a proper New Moon? This delightful Ruby gem connects you to the cosmic dance above, using the official US Naval Observatory (USNO) API to bring celestial timing to your fingertips.

Whether you're building a werewolf scheduling app, a vampire calendar, or just want to impress your users with lunar-powered features, MoonPhaseTracker has got your back under every phase of the moon.

**🎯 Accuracy: ~85-90%** *(Good enough for lunar calendars, probably too precise for howling)*

## ✨ What Makes This Gem Shine

- 🌑 **Time Travel Through Lunar Cycles** - Query moon phases by month, year, or from any date your heart desires
- 🌒 **The Full Lunar Symphony** - Complete 8-phase support (4 major crescendos + 4 melodic interludes)
- 🌓 **Simple as Moonlight** - An interface so intuitive, even a sleepy developer can use it at 3 AM
- 🌔 **Navy-Grade Precision** - Official USNO data because the Navy doesn't mess around with moon phases
- 🌕 **Emoji Magic** - Visual moon phases that spark joy in your terminal
- 🌖 **Mathematical Lunar Poetry** - Interpolated intermediate phases for when precision meets artistry
- 🌗 **Truth in Advertising** - Clear indicators showing official vs calculated phases (no moon phase imposters here!)
- 🌘 **Memory Like an Elephant** - Automatic caching because nobody likes waiting for the moon
- ⚡ **Bulletproof & Graceful** - Error handling that fails as elegantly as moonbeams
- 🚦 **API Etiquette** - Respectful rate limiting because even the Navy deserves a break

## 🚀 Summoning the Lunar Powers

*Ready to add some celestial magic to your Ruby project?*

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

## 🎭 Lunar Adventures Await

*Time to dance with the moon phases like a cosmic choreographer!*

### 🌟 The Essential Four - Your Lunar Greatest Hits

*Start your journey with the moon's main characters: the celestial quartet that's been stealing hearts since ancient times.*

```ruby
require 'moon_phase_tracker'

# Moon phases for August 2025 (4 major phases only)
phases = MoonPhaseTracker.phases_for_month(2025, 8)
puts phases.first.to_s
# => "🌑 New Moon - 2025-08-04 at 11:13"
# (Perfect timing for new beginnings!)

# All phases for 2025 - your yearly lunar roadmap
year_phases = MoonPhaseTracker.phases_for_year(2025)

# Next 6 phases from a specific date - peek into the future
future_phases = MoonPhaseTracker.phases_from_date("2025-08-01", 6)
```

### 🎨 The Full Lunar Canvas - All 8 Phases in Their Glory

*For the lunar perfectionists who want the complete story, not just the highlights reel.*

```ruby
require 'moon_phase_tracker'

# All 8 phases for August 2025 - the complete lunar symphony
all_phases = MoonPhaseTracker.all_phases_for_month(2025, 8)
all_phases.each do |phase|
  indicator = phase.interpolated ? "~ " : "  "  # ~ means "calculated with love"
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

# All 8 phases for entire year - your cosmic annual planner
all_year_phases = MoonPhaseTracker.all_phases_for_year(2025)

# All 8 phases from specific date (2 lunar cycles) - the extended edition
extended_phases = MoonPhaseTracker.all_phases_from_date("2025-08-01", 2)
```

### 🔮 Instant Moon Phase - No API, No Waiting

*What phase is the moon right now? How bright is it? Pure math, instant answer.*

These methods use a synodic month calculation — no API calls, no network, no rate limits. Perfect for display UIs and real-time widgets.

```ruby
require 'moon_phase_tracker'

# What's the moon doing right now?
phase = MoonPhaseTracker.current_phase
puts phase.to_s
# => "🌔 Waxing Gibbous - 2025-08-15 at 14:30"
puts phase.illumination  # => 78.5 (percent)
puts phase.lunar_age     # => 12.3 (days since last new moon)
puts phase.source        # => :calculated

# Phase at any date/time - past or future
phase = MoonPhaseTracker.phase_at(Time.utc(2025, 6, 11, 7, 44))
puts phase.name          # => "Full Moon"
puts phase.illumination  # => ~100.0

# Just the illumination percentage
illum = MoonPhaseTracker.illumination(Date.today)
puts "#{illum.round(1)}% illuminated"

# Works with Date, Time, DateTime, or String
MoonPhaseTracker.phase_at(Date.new(2025, 1, 15))
MoonPhaseTracker.phase_at("2025-01-15")
MoonPhaseTracker.phase_at(DateTime.now)
```

> **Accuracy note:** The synodic model gives the correct named phase ~99% of the time. Within ~6 hours of a phase boundary, it may differ from USNO API data. The API path gives precision for scheduling; the calculator path gives instant answers for display.

### 🎯 The Tracker Class - Your Personal Lunar Assistant

*Think of it as your moon phase butler, always ready to serve up cosmic timing with a bow tie.*

```ruby
tracker = MoonPhaseTracker::Tracker.new

# Automatic formatting for display - because presentation matters
august_phases = tracker.phases_for_month(2025, 8)
formatted = tracker.format_phases(august_phases, "August Phases")
puts formatted

# Next moon phase - your cosmic fortune telling
next_phase = tracker.next_phase
puts next_phase.to_s

# Current month phases - what's happening in your lunar neighborhood
current_month = tracker.current_month_phases

# Instant phase at any date - no API call needed
phase = tracker.phase_at("2025-06-11")
puts phase.illumination  # => Float (percent)

# Just the illumination number
illum = tracker.illumination("2025-06-11")

# Current phase right now
puts tracker.current_phase
```

### 🔍 Getting Personal with Moon Phases

*Each phase has its own personality - let's get to know them intimately.*

```ruby
phase = phases.first

# Phase information
puts phase.name          # "New Moon"
puts phase.symbol        # "🌑" (isn't it beautiful?)
puts phase.formatted_date # "2025-08-04"
puts phase.formatted_time # "11:13" (UTC - the moon doesn't do timezones)
puts phase.interpolated   # false (certified genuine USNO data)

# Working with interpolated phases - the mathematically gifted ones
interpolated_phase = all_phases.find(&:interpolated)
puts interpolated_phase.interpolated  # true (calculated with mathematical precision)
puts interpolated_phase.name         # "Waxing Crescent"
puts interpolated_phase.symbol       # "🌒" (still adorable)

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
#   interpolated: false,
#   source: :api,           # :api, :interpolated, or :calculated
#   illumination: nil,      # Float for calculated phases, nil for API
#   lunar_age: nil          # Float for calculated phases, nil for API
# }

# Date checks - lunar detective work
phase.in_month?(2025, 8)  # => true (August moon confirmed!)
phase.in_year?(2025)      # => true (definitely a 2025 vintage)
```

### 🛡️ When the Moon Plays Hard to Get

*Even celestial bodies have bad days. Here's how to handle lunar tantrums gracefully.*

```ruby
begin
  phases = MoonPhaseTracker.phases_for_month(2025, 8)
rescue MoonPhaseTracker::NetworkError => e
  puts "Network hiccup: #{e.message}" # The internet is having a moment
rescue MoonPhaseTracker::APIError => e
  puts "API tantrum: #{e.message}"   # The Navy API is feeling moody
rescue MoonPhaseTracker::InvalidDateError => e
  puts "Time travel error: #{e.message}" # That date doesn't exist in this dimension
end
```

### 🎪 Real-World Lunar Magic

*Because theory is nice, but seeing the moon phases in action is where the real magic happens.*

#### Hybrid Architecture: USNO for Scheduling, Calculator for Display

The API gives you exact dates. The calculator gives you instant answers. Use both — a background job populates a `lunar_phases` table with USNO data, and `LunarCalculator` handles the real-time display layer.

```ruby
# app/jobs/sync_lunar_phases_job.rb
class SyncLunarPhasesJob < ApplicationJob
  def perform(year = Date.current.year)
    phases = MoonPhaseTracker.all_phases_for_year(year)

    phases.each do |phase|
      LunarPhase.upsert(
        {
          name: phase.name,
          phase_type: phase.phase_type.to_s,
          exact_at: phase.to_h[:utc_time],
          source: phase.source.to_s
        },
        unique_by: :exact_at
      )
    end
  end
end
```

```ruby
# app/models/lunar_phase.rb
class LunarPhase < ApplicationRecord
  scope :upcoming, -> { where("exact_at > ?", Time.current).order(:exact_at) }
  scope :next_full_moon, -> { upcoming.where(phase_type: "full_moon").first }
end
```

```ruby
# app/helpers/moon_helper.rb
module MoonHelper
  def moon_badge(date = Date.current)
    phase = MoonPhaseTracker.phase_at(date)
    "#{phase.symbol} #{phase.illumination.round}%"
  end
end
```

Two data sources, each doing what they do best. The table owns scheduling precision (notifications, rituals, content triggers). The calculator owns display (emoji, illumination percentage, "what phase is it right now?"). They never step on each other's toes.

See the `examples/usage_example.rb` and `examples/eight_phases_example.rb` files for more usage examples.

## 📚 The Lunar Grimoire - Complete API Spellbook

*Your comprehensive guide to all the lunar incantations at your disposal.*

### 🎭 The Core Cast - 4 Major Phase Methods

*The essential methods that'll get you 80% of your lunar needs covered.*

- `MoonPhaseTracker.phases_for_month(year, month)` - Major phases for a specific month
- `MoonPhaseTracker.phases_for_year(year)` - All major phases for a year
- `MoonPhaseTracker.phases_from_date(date, num_phases)` - Major phases from a specific date

### 🔮 Instant Lookup - No API Required

*Pure math, zero latency. For when you need the moon right now.*

- `MoonPhaseTracker.phase_at(date)` - Phase at any date/time (returns `Phase` with illumination)
- `MoonPhaseTracker.illumination(date)` - Illumination percentage (returns `Float` 0..100)
- `MoonPhaseTracker.current_phase` - Phase right now (shortcut for `phase_at(Time.now.utc)`)

No API calls — pure math under the hood.

### 🌈 The Full Spectrum - 8-Phase Methods for Lunar Completionists

*For those who believe in doing things thoroughly (and slightly obsessively).*

- `MoonPhaseTracker.all_phases_for_month(year, month)` - All 8 phases for a specific month
- `MoonPhaseTracker.all_phases_for_year(year)` - All 8 phases for a year
- `MoonPhaseTracker.all_phases_from_date(date, num_cycles)` - All 8 phases from a specific date

### 🎨 Meet the Lunar Cast - All 8 Phase Personalities

#### 🏆 The Main Characters (Official USNO Data)
*These are the A-listers - certified by the Navy, guaranteed to impress.*
- 🌑 `:new_moon` - New Moon *(The mysterious beginning)*
- 🌓 `:first_quarter` - First Quarter *(Half-lit and growing strong)*
- 🌕 `:full_moon` - Full Moon *(The showstopper, the main event)*
- 🌗 `:last_quarter` - Last Quarter *(Gracefully waning)*

#### 🎭 The Supporting Cast (Interpolated ~85-90% accuracy)
*The understudies that complete the story - mathematically calculated with love.*
- 🌒 `:waxing_crescent` - Waxing Crescent *(The optimistic youngster)*
- 🌔 `:waxing_gibbous` - Waxing Gibbous *(Almost there, building anticipation)*
- 🌖 `:waning_gibbous` - Waning Gibbous *(The wise elder, still radiant)*
- 🌘 `:waning_crescent` - Waning Crescent *(The gentle farewell)*

### 🏷️ Phase Sources - Know Where Your Data Comes From

*Every phase carries a passport stamped with its origin story.*

| Source | Meaning | When |
|--------|---------|------|
| `:api` | Official USNO data | `phases_for_month`, `phases_for_year`, etc. |
| `:interpolated` | Calculated between two API phases | `all_phases_for_month`, `all_phases_for_year`, etc. |
| `:calculated` | Pure synodic math model | `phase_at`, `illumination`, `current_phase` |

```ruby
phase = MoonPhaseTracker.phase_at(Date.today)
phase.source        # => :calculated
phase.illumination  # => 65.3 (percent)
phase.lunar_age     # => 10.2 (days since last new moon)
```

## ⚓ Our Trusted Cosmic Oracle

*We get our lunar wisdom from the finest source - the folks who navigate the seven seas by the stars.*

This gem uses the official US Naval Observatory (USNO) API - because when it comes to celestial navigation, you want the folks who've been steering ships by the stars for centuries:

- **Base URL**: https://aa.usno.navy.mil/api/moon/phases/
- **API Version**: 4.0.1 (battle-tested and Navy-approved)
- **Documentation**: https://aa.usno.navy.mil/data/api

All times are provided in Universal Time (UTC) - because the moon doesn't care about your timezone preferences, and neither should precise astronomical data.

## 🚦 Playing Nice with the Navy - Rate Limiting with Style

*Because even cosmic APIs need coffee breaks, and we're not monsters.*

Think of rate limiting as the polite pause between questions when chatting with a wise oracle. We implement respectful rate limiting to keep the USNO Navy API happy (and responsive). By default, we're as patient as a monk - **1 request per second** with the restraint of a zen master.


### 🧘 The Zen Approach - Default Rate Limiting

*Slow and steady wins the lunar race.*

```ruby
# Default: 1 request per second - the patient approach
tracker = MoonPhaseTracker::Tracker.new

# Check current rate limit configuration - know thy limits
puts tracker.rate_limit_info
# => {:requests_per_second=>1.0, :burst_size=>1, :available_tokens=>1}

# Multiple requests will be automatically rate limited - watch the magic
start = Time.now
tracker.phases_for_year(2025)  # Immediate (first one's free!)
tracker.phases_for_year(2024)  # Waits ~1 second (patience, young padawan)
puts "Total time: #{Time.now - start}s"  # ~1.0 seconds
```

### ⚡ Need for Speed? - Custom Rate Limiting

*For when you want to live life in the fast lane (but still be respectful).*

```ruby
# Create custom rate limiter: 3 requests per second, burst of 2 - living a little
rate_limiter = MoonPhaseTracker::RateLimiter.new(
  requests_per_second: 3.0,
  burst_size: 2
)

tracker = MoonPhaseTracker::Tracker.new(rate_limiter: rate_limiter)

# Burst requests are immediate, then rate limited - controlled excitement
tracker.phases_for_year(2025)  # Immediate (wheee!)
tracker.phases_for_year(2024)  # Immediate (double wheee!)
tracker.phases_for_year(2023)  # Waits ~0.33 seconds (and... breathe)
```

### 🌍 Set It and Forget It - Environment Variables

*Configure once, smile forever.*

```ruby
# Set via environment variables - the lazy developer's paradise
ENV["MOON_PHASE_RATE_LIMIT"] = "2.5"
ENV["MOON_PHASE_BURST_SIZE"] = "3"

tracker = MoonPhaseTracker::Tracker.new
puts tracker.rate_limit_info
# => {:requests_per_second=>2.5, :burst_size=>3, :available_tokens=>3}
```

### 🏁 Living Dangerously - Disabling Rate Limiting

*For the rebels and the reckless (use responsibly, dear lunar adventurer).*

```ruby
# Disable rate limiting completely - for the speed demons
ENV["MOON_PHASE_RATE_LIMIT"] = "0"

tracker = MoonPhaseTracker::Tracker.new
puts tracker.rate_limit_info  # => nil (no limits, no safety net!)

# Or pass nil explicitly - the explicit rebel
tracker = MoonPhaseTracker::Tracker.new(rate_limiter: nil)
```

### 🔬 Under the Hood - Rate Limit Monitoring

*For the control freaks and performance enthusiasts among us.*

```ruby
rate_limiter = MoonPhaseTracker::RateLimiter.new(
  requests_per_second: 1.0,
  burst_size: 2
)

# Check if request can proceed without waiting - the crystal ball
puts rate_limiter.can_proceed?  # => true (or false if you've been naughty)

# Check current token status - your digital wallet
puts rate_limiter.configuration
# => {:requests_per_second=>1.0, :burst_size=>2, :available_tokens=>2}

# Manual rate limiting control - take the wheel
rate_limiter.throttle  # Waits if necessary and consumes token (om nom nom)
```

### 🪣 The Magic Behind the Curtain - Token Bucket Algorithm

*The elegant dance of digital tokens that keeps everything flowing smoothly.*

The rate limiter uses a token bucket algorithm:

- **Tokens**: Represent available requests
- **Bucket Size**: Maximum burst requests allowed
- **Refill Rate**: How quickly tokens are replenished
- **Thread Safe**: Handles concurrent requests safely

## 🛠️ Join the Lunar Development Cult

*Want to contribute to the cosmic cause? We welcome fellow moon enthusiasts!*

After checking out the repo, run `bin/setup` to install dependencies (like preparing your lunar laboratory). Then, run `rake spec` to run the tests (because even moon phases need quality control). You can also run `bin/console` for an interactive prompt that will allow you to experiment (perfect for midnight coding sessions under the actual moon).

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org) (sharing lunar magic with the world!).

## 🤝 Become a Lunar Contributor

*Every great gem needs a community of stargazers and code wizards.*

Bug reports and pull requests are welcome on GitHub at https://github.com/dklima/moon_phase_tracker. Found a bug? Think of it as discovering a new lunar crater - exciting stuff! This project is intended to be a safe, welcoming space for collaboration, where all contributors can shine as bright as a Full Moon. Contributors are expected to adhere to the [code of conduct](https://github.com/dklima/moon_phase_tracker/blob/main/CODE_OF_CONDUCT.md).

## 📜 Legal Lunar Stuff

*Even moon phases need proper paperwork.*

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## 🌟 Lunar Community Guidelines

*We believe in creating a space as welcoming as moonlight on a summer evening.*

Everyone interacting in the MoonPhaseTracker project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/dklima/moon_phase_tracker/blob/main/CODE_OF_CONDUCT.md). Together, we create a community as harmonious as the lunar cycles themselves.
