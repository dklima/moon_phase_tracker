# frozen_string_literal: true

module MoonPhaseTracker
  class Phase
    class Formatter
      INVALID_DATE_MESSAGE = "Invalid date"
      INVALID_TIME_MESSAGE = "Invalid time"
      DATE_FORMAT = "%Y-%m-%d"
      TIME_FORMAT = "%H:%M"

      def self.format_date(date)
        return INVALID_DATE_MESSAGE unless date

        date.strftime(DATE_FORMAT)
      end

      def self.format_time(time)
        return INVALID_TIME_MESSAGE unless time

        time.strftime(TIME_FORMAT)
      end

      def self.format_phase_description(name, symbol, date, time)
        formatted_date = format_date(date)
        formatted_time = format_time(time)

        "#{symbol} #{name} - #{formatted_date} at #{formatted_time}"
      end

      def self.build_hash_representation(phase_attributes)
        {
          name: phase_attributes[:name],
          phase_type: phase_attributes[:phase_type],
          date: format_date(phase_attributes[:date]),
          time: format_time(phase_attributes[:time]),
          symbol: phase_attributes[:symbol],
          iso_date: phase_attributes[:date]&.iso8601,
          utc_time: phase_attributes[:time]&.utc&.iso8601,
          interpolated: phase_attributes[:interpolated],
          source: phase_attributes[:source],
          illumination: phase_attributes[:illumination],
          lunar_age: phase_attributes[:lunar_age]
        }
      end
    end
  end
end
