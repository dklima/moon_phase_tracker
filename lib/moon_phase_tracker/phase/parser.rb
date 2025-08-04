# frozen_string_literal: true

require "date"
require "time"

module MoonPhaseTracker
  class Phase
    class Parser
      def self.build_date(phase_data)
        year = phase_data["year"]
        month = phase_data["month"]
        day = phase_data["day"]

        return nil unless valid_date_components?(year, month, day)

        Date.new(year.to_i, month.to_i, day.to_i)
      rescue Date::Error
        nil
      end

      def self.parse_time(time_string)
        return nil unless time_string

        Time.parse("#{time_string} UTC")
      rescue ArgumentError
        nil
      end

      def self.valid_date_components?(year, month, day)
        year && month && day
      end

      private_class_method :valid_date_components?
    end
  end
end
