# frozen_string_literal: true

require_relative "../phase"

module MoonPhaseTracker
  class PhaseCalculator
    class PhaseInterpolator
      MAX_INTERPOLATION_INTERVAL = 11.07
      HOURS_PER_DAY = 24
      SECONDS_PER_HOUR = 3600
      DEFAULT_HOUR = 12
      INTERMEDIATE_PHASES = [
        { name: "Waxing Crescent", offset_ratio: 0.5, between: %i[new_moon first_quarter] },
        { name: "Waxing Gibbous", offset_ratio: 0.5, between: %i[first_quarter full_moon] },
        { name: "Waning Gibbous", offset_ratio: 0.5, between: %i[full_moon last_quarter] },
        { name: "Waning Crescent", offset_ratio: 0.5, between: %i[last_quarter new_moon] }
      ].freeze

      def calculate_between(phase1, phase2)
        return nil unless interpolation_possible?(phase1, phase2)

        intermediate_config = find_intermediate_config(phase1.phase_type, phase2.phase_type)
        return nil unless intermediate_config

        create_intermediate_phase(phase1, phase2, intermediate_config)
      end

      private

      def interpolation_possible?(phase1, phase2)
        return false unless valid_phases?(phase1, phase2)
        return false unless valid_dates?(phase1, phase2)
        
        interval_within_limits?(phase1, phase2)
      end

      def valid_phases?(phase1, phase2)
        phase1 && phase2
      end

      def valid_dates?(phase1, phase2)
        phase1.date && phase2.date
      end

      def interval_within_limits?(phase1, phase2)
        days_between = calculate_days_between(phase1.date, phase2.date)
        days_between.positive? && days_between <= MAX_INTERPOLATION_INTERVAL
      end

      def calculate_days_between(date1, date2)
        (date2 - date1).to_f
      end

      def find_intermediate_config(type1, type2)
        INTERMEDIATE_PHASES.find { |config| config[:between] == [type1, type2] }
      end

      def create_intermediate_phase(phase1, phase2, config)
        intermediate_datetime = calculate_intermediate_datetime(phase1, phase2, config)
        return nil unless intermediate_datetime

        phase_data = build_phase_data(intermediate_datetime, config[:name])
        Phase.new(phase_data, interpolated: true)
      rescue Date::Error, ArgumentError => e
        warn "Failed to create intermediate phase: #{e.class}"
        nil
      end

      def calculate_intermediate_datetime(phase1, phase2, config)
        total_hours = calculate_total_hours_between(phase1, phase2)
        intermediate_hours = total_hours * config[:offset_ratio]
        
        base_time = determine_base_time(phase1)
        base_time + (intermediate_hours * SECONDS_PER_HOUR)
      end

      def calculate_total_hours_between(phase1, phase2)
        days_between = calculate_days_between(phase1.date, phase2.date)
        hours_from_days = days_between * HOURS_PER_DAY
        
        return hours_from_days unless both_phases_have_time?(phase1, phase2)
        
        time_difference_hours = calculate_time_difference_hours(phase1.time, phase2.time)
        hours_from_days + time_difference_hours
      end

      def both_phases_have_time?(phase1, phase2)
        phase1.time && phase2.time
      end

      def calculate_time_difference_hours(time1, time2)
        (time2 - time1) / SECONDS_PER_HOUR.to_f
      end

      def determine_base_time(phase)
        return phase.time if phase.time
        
        Time.new(phase.date.year, phase.date.month, phase.date.day,
                 DEFAULT_HOUR, 0, 0, "+00:00")
      end

      def build_phase_data(datetime, name)
        {
          "phase" => name,
          "year" => datetime.year,
          "month" => datetime.month,
          "day" => datetime.day,
          "time" => datetime.strftime("%H:%M")
        }
      end
    end
  end
end
