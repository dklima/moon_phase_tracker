# frozen_string_literal: true

module MoonPhaseTracker
  class Phase
    class Comparator
      def self.compare_phases(phase_a, phase_b)
        return nil unless phases_comparable?(phase_a, phase_b)

        date_comparison = compare_dates(phase_a.date, phase_b.date)
        return date_comparison unless date_comparison.zero?

        compare_times(phase_a.time, phase_b.time)
      end

      def self.in_month?(phase_date, year, month)
        return false unless phase_date

        phase_date.year == year && phase_date.month == month
      end

      def self.in_year?(phase_date, year)
        return false unless phase_date

        phase_date.year == year
      end

      def self.phases_comparable?(phase_a, phase_b)
        phase_a.is_a?(Phase) && phase_b.is_a?(Phase)
      end

      def self.compare_dates(date_a, date_b)
        date_a <=> date_b
      end

      def self.compare_times(time_a, time_b)
        time_a <=> time_b
      end

      private_class_method :phases_comparable?, :compare_dates, :compare_times
    end
  end
end
