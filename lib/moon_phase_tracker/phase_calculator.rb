# frozen_string_literal: true

require "date"
require_relative "phase_calculator/phase_interpolator"
require_relative "phase_calculator/cycle_estimator"

module MoonPhaseTracker
  class PhaseCalculator
    def initialize(major_phases)
      @major_phases = major_phases.sort
      @interpolator = PhaseInterpolator.new
      @cycle_estimator = CycleEstimator.new
    end

    def calculate_all_phases
      all_phases = @major_phases.dup
      
      add_consecutive_intermediate_phases(all_phases)
      add_cycle_transition_phases(all_phases)
      
      all_phases.sort
    end

    private

    def add_consecutive_intermediate_phases(all_phases)
      @major_phases.each_cons(2) do |phase1, phase2|
        intermediate_phase = @interpolator.calculate_between(phase1, phase2)
        all_phases << intermediate_phase if intermediate_phase
      end
    end

    def add_cycle_transition_phases(all_phases)
      return unless @major_phases.size >= 2

      last_phase = @major_phases.last
      next_cycle_phase = @cycle_estimator.estimate_next_cycle_phase(last_phase)
      
      return unless next_cycle_phase
      
      intermediate_phase = @interpolator.calculate_between(last_phase, next_cycle_phase)
      all_phases << intermediate_phase if intermediate_phase
    end
  end
end
