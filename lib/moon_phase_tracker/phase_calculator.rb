# frozen_string_literal: true

require "date"

module MoonPhaseTracker
  class PhaseCalculator
    LUNAR_CYCLE = 29.530588853
    PHASE_INTERVAL = LUNAR_CYCLE / 4.0
    INTERMEDIATE_PHASES = [
      { name: "Waxing Crescent", offset_ratio: 0.5, between: %i[new_moon first_quarter] },
      { name: "Waxing Gibbous", offset_ratio: 0.5, between: %i[first_quarter full_moon] },
      { name: "Waning Gibbous", offset_ratio: 0.5, between: %i[full_moon last_quarter] },
      { name: "Waning Crescent", offset_ratio: 0.5, between: %i[last_quarter new_moon] }
    ].freeze

    def initialize(major_phases)
      @major_phases = major_phases.sort
    end

    def calculate_all_phases
      all_phases = @major_phases.dup

      @major_phases.each_cons(2) do |phase1, phase2|
        intermediate = calculate_intermediate_phase(phase1, phase2)
        all_phases << intermediate if intermediate
      end

      if @major_phases.size >= 2
        last_phase = @major_phases.last
        first_phase = find_next_cycle_phase(last_phase)
        if first_phase
          intermediate = calculate_intermediate_phase(last_phase, first_phase)
          all_phases << intermediate if intermediate
        end
      end

      all_phases.sort
    end

    private

    def calculate_intermediate_phase(phase1, phase2)
      return nil unless can_interpolate?(phase1, phase2)

      intermediate_config = find_intermediate_config(phase1.phase_type, phase2.phase_type)
      return nil unless intermediate_config

      days_between = (phase2.date - phase1.date).to_f
      hours_between = days_between * 24

      if phase1.time && phase2.time
        time_diff = (phase2.time - phase1.time) / 3600.0 # Convert to hours
        hours_between += time_diff
      end

      intermediate_hours = hours_between * intermediate_config[:offset_ratio]
      intermediate_datetime = if phase1.time
                                phase1.time + (intermediate_hours * 3600)
      else
                                Time.new(phase1.date.year, phase1.date.month, phase1.date.day, 12, 0, 0,
                                         "+00:00") + (intermediate_hours * 3600)
      end

      phase_data = {
        "phase" => intermediate_config[:name],
        "year" => intermediate_datetime.year,
        "month" => intermediate_datetime.month,
        "day" => intermediate_datetime.day,
        "time" => intermediate_datetime.strftime("%H:%M")
      }

      Phase.new(phase_data, interpolated: true)
    rescue StandardError
      nil
    end

    def can_interpolate?(phase1, phase2)
      return false unless phase1 && phase2
      return false unless phase1.date && phase2.date

      days_between = (phase2.date - phase1.date).to_f
      days_between.positive? && days_between <= (PHASE_INTERVAL * 1.5)
    end

    def find_intermediate_config(type1, type2)
      INTERMEDIATE_PHASES.find do |config|
        config[:between] == [ type1, type2 ]
      end
    end

    def find_next_cycle_phase(last_phase)
      # Look for a new moon that comes after the last phase
      # This is a simplified approach - in a real implementation,
      # you might want to fetch additional data or use astronomical calculations

      # For now, we'll estimate based on the lunar cycle
      estimated_next_new_moon_date = last_phase.date + PHASE_INTERVAL

      # Create an estimated new moon phase for calculation purposes
      phase_data = {
        "phase" => "New Moon",
        "year" => estimated_next_new_moon_date.year,
        "month" => estimated_next_new_moon_date.month,
        "day" => estimated_next_new_moon_date.day,
        "time" => last_phase.time ? last_phase.time.strftime("%H:%M") : "12:00"
      }

      Phase.new(phase_data)
    rescue StandardError
      nil
    end
  end
end
