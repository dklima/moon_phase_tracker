# frozen_string_literal: true

require_relative "../phase"

module MoonPhaseTracker
  class PhaseCalculator
    class CycleEstimator
      LUNAR_CYCLE_DAYS = 29.530588853
      PHASE_INTERVAL_DAYS = LUNAR_CYCLE_DAYS / 4.0
      DEFAULT_TIME = "12:00"

      def estimate_next_cycle_phase(last_phase)
        return nil unless valid_phase_for_estimation?(last_phase)

        estimated_date = calculate_estimated_date(last_phase)
        phase_data = build_estimated_phase_data(estimated_date, last_phase)

        Phase.new(phase_data, source: :interpolated)
      rescue Date::Error, ArgumentError => e
        warn "Failed to estimate next cycle phase: #{e.class}"
        nil
      end

      private

      def valid_phase_for_estimation?(phase)
        phase && phase.date
      end

      def calculate_estimated_date(last_phase)
        last_phase.date + PHASE_INTERVAL_DAYS
      end

      def build_estimated_phase_data(estimated_date, reference_phase)
        {
          "phase" => "New Moon",
          "year" => estimated_date.year,
          "month" => estimated_date.month,
          "day" => estimated_date.day,
          "time" => determine_estimated_time(reference_phase)
        }
      end

      def determine_estimated_time(reference_phase)
        return reference_phase.time.strftime("%H:%M") if reference_phase.time

        DEFAULT_TIME
      end
    end
  end
end
