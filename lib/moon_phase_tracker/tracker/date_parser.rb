# frozen_string_literal: true

require "date"

module MoonPhaseTracker
  # Service class for parsing different date formats
  # Handles multiple input types with consistent error handling
  class DateParser
    # Parse various date formats into Date object
    # @param date [String, Date, Time] Input date in various formats
    # @return [Date] Parsed date object
    # @raise [InvalidDateError] If date cannot be parsed
    def parse(date)
      return parse_by_type(date) if valid_date_type?(date)

      raise InvalidDateError, "Invalid date format: #{date.class}"
    rescue Date::Error => e
      raise InvalidDateError, "Invalid date: #{date} (#{e.message})"
    end

    private

    # Check if date is of a valid type
    # @param date [Object] Date to check
    # @return [Boolean] True if date type is supported
    def valid_date_type?(date)
      [String, Date, Time].any? { |klass| date.is_a?(klass) }
    end

    # Parse date based on its type
    # @param date [String, Date, Time] Date to parse
    # @return [Date] Parsed date
    def parse_by_type(date)
      case date
      when String
        Date.parse(date)
      when Date
        date
      when Time
        date.to_date
      end
    end
  end
end