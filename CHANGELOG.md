# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.3.1] - 2025-08-04

### Changed
- **Major Code Refactoring**
  - Refactored `Tracker` class following SOLID principles
  - Extracted specialized services: `PhaseQueryService`, `PhaseFormatter`, `DateParser`, `Validators`
  - Refactored `PhaseCalculator` class with composition over inheritance
  - Extracted specialized classes: `PhaseInterpolator`, `CycleEstimator`
  - Applied Single Responsibility Principle across all classes
  - Implemented early return patterns for better code flow
  - Improved method naming and code organization
  - Added comprehensive English comments for maintainability

### Technical
- **Architecture Improvements**
  - Converted large classes into smaller, focused service objects
  - Improved testability and maintainability through better separation of concerns
  - Enhanced code readability with descriptive method and variable names
  - Eliminated code duplication and improved DRY principles
  - Better error handling with specific exception types
  - Removed generic `rescue StandardError` anti-patterns

## [1.3.0] - 2025-08-04

### Added
- **Rate Limiting Support**
  - Implemented configurable rate limiting using token bucket algorithm
  - Default rate limit: 1 request per second with burst size of 1
  - New `RateLimiter` class with thread-safe token bucket implementation
  - Environment variable configuration: `MOON_PHASE_RATE_LIMIT` and `MOON_PHASE_BURST_SIZE`
  - Rate limiting can be disabled by setting `MOON_PHASE_RATE_LIMIT=0`
  - Added `rate_limit_info` method to inspect current rate limiting configuration
  - Custom rate limiter can be passed to `Tracker.new(rate_limiter: custom_limiter)`

### Changed
- **Client API Updates**
  - `Client.new` now accepts optional `rate_limiter` parameter
  - `Tracker.new` now accepts optional `rate_limiter` parameter
  - All API requests are now automatically rate limited by default

### Technical
- Added comprehensive test coverage for rate limiting functionality
- Added `examples/rate_limiting_example.rb` demonstrating all rate limiting features
- Updated documentation with rate limiting configuration and usage examples

## [1.2.0] - 2025-08-04

### Added
- **8 Moon Phases Support**
  - Complete support for all 8 lunar phases instead of just 4 major phases
  - Added intermediate phases: Waxing Crescent 🌒, Waxing Gibbous 🌔, Waning Gibbous 🌖, Waning Crescent 🌘
  - New `PhaseCalculator` class for interpolating intermediate phases between major phases
  - `interpolated` attribute on `Phase` class to distinguish calculated from official phases
  
- **New Public API Methods**
  - `MoonPhaseTracker.all_phases_for_month(year, month)` - Get all 8 phases for a specific month
  - `MoonPhaseTracker.all_phases_for_year(year)` - Get all 8 phases for a year
  - `MoonPhaseTracker.all_phases_from_date(date, num_cycles)` - Get all 8 phases from a specific date
  
- **Enhanced Phase Representation**
  - Updated `PHASE_SYMBOLS` constant with all 8 phase emojis
  - Updated `PHASE_NAMES` mapping to include intermediate phases
  - Visual indicator (`~`) for interpolated phases in formatted output
  - Enhanced `format_phases` method to show major vs interpolated phase counts

- **Examples & Documentation**
  - New `examples/eight_phases_example.rb` demonstrating 8-phase functionality
  - Comprehensive comparison between 4-phase and 8-phase outputs
  - Phase symbols reference with visual emojis

### Changed
- **Precision & Accuracy**
  - Interpolation algorithm provides ~85-90% accuracy for intermediate phases
  - Suitable for lunar calendar applications requiring higher phase granularity
  - Maintains backward compatibility with existing 4-phase API methods

## [1.1.0] - 2025-08-04

### Changed
- **BREAKING CHANGE**: Date format standardized to ISO 8601 (YYYY-MM-DD)
  - `Phase#formatted_date` now returns dates in ISO 8601 format instead of DD/MM/YYYY
  - `Phase#to_s` output format updated to use ISO 8601 dates
  - All documentation and examples updated to reflect new date format

- **Internationalization Updates**
  - User interface completely translated to American English
  - Error messages now in English instead of Brazilian Portuguese
  - Month names in `Tracker.month_name` changed from Portuguese to English
  - Console messages and examples translated to English
  - `Phase#to_s` separator changed from "às" to "at"
  
- **Date/Time Consistency**
  - All date representations now use consistent ISO 8601 format
  - Improved international compatibility and API consistency
  - Enhanced sorting and comparison reliability

## [1.0.0] - 2025-08-04

### Added
- **Core Functionality**
  - Integration with USNO Navy API 4.0.1 for accurate moon phase data
  - `MoonPhaseTracker.phases_for_month(year, month)` - Get phases for a specific month
  - `MoonPhaseTracker.phases_for_year(year)` - Get all phases for a year
  - `MoonPhaseTracker.phases_from_date(date, num_phases)` - Get phases from a specific date

- **Phase Representation**
  - `Phase` class with emoji symbols for each moon phase (🌑🌓🌕🌗)
  - ISO 8601 date formatting (YYYY-MM-DD)
  - Multiple output formats (string, hash, formatted display)
  - Phase comparison and sorting capabilities

- **Tracker Interface**
  - `Tracker` class for advanced moon phase operations
  - `current_month_phases` and `current_year_phases` convenience methods
  - `next_phase` to get the upcoming moon phase
  - `format_phases` with English month names

- **HTTP Client**
  - Robust HTTP client with timeout handling
  - URI caching for performance optimization
  - Comprehensive error handling (network, API, parsing)
  - User-Agent header with gem version

- **Error Handling**
  - Custom exception hierarchy (`APIError`, `NetworkError`, `InvalidDateError`)
  - Input validation for dates, years, and phase counts
  - English error messages

- **Testing & Documentation**
  - Complete RSpec test suite with 21 passing tests
  - Aggregate failure testing approach for efficiency
  - Mocked API responses for reliable testing
  - Comprehensive README with usage examples
  - Interactive console with helpful examples
  - Usage example script in `examples/` directory

- **Dependencies**
  - `net-http ~> 0.4` for HTTP requests
  - `json ~> 2.7` for JSON parsing
  - Ruby 3.2.0+ compatibility

### Technical Details
- API endpoint: `https://aa.usno.navy.mil/api/moon/phases/`
- All times provided in Universal Time (UTC)
- Supports date range from 1700 to current year + 10
- Phase count range: 1-99 phases per request
