# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
