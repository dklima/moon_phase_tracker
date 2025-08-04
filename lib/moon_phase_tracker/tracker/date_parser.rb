# frozen_string_literal: true

require "date"

module MoonPhaseTracker
  class DateParser
    def parse(date)
      return parse_by_type(date) if valid_date_type?(date)

      raise InvalidDateError, "Invalid date format: #{date.class}"
    rescue Date::Error => e
      raise InvalidDateError, "Invalid date: #{date} (#{e.message})"
    end

    private

    def valid_date_type?(date)
      [ String, Date, Time ].any? { |klass| date.is_a?(klass) }
    end

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
