# frozen_string_literal: true

require_relative "moon_phase_tracker/version"
require_relative "moon_phase_tracker/client"
require_relative "moon_phase_tracker/phase"
require_relative "moon_phase_tracker/phase_calculator"
require_relative "moon_phase_tracker/tracker"

module MoonPhaseTracker
  class Error < StandardError; end
  class APIError < Error; end
  class NetworkError < Error; end
  class InvalidDateError < Error; end

  def self.phases_for_month(year, month)
    Tracker.new.phases_for_month(year, month)
  end

  def self.phases_for_year(year)
    Tracker.new.phases_for_year(year)
  end

  def self.phases_from_date(date, num_phases = 12)
    Tracker.new.phases_from_date(date, num_phases)
  end

  # Get all 8 phases (4 major + 4 intermediate) for a month
  def self.all_phases_for_month(year, month)
    Tracker.new.all_phases_for_month(year, month)
  end

  # Get all 8 phases (4 major + 4 intermediate) for a year
  def self.all_phases_for_year(year)
    Tracker.new.all_phases_for_year(year)
  end

  # Get all 8 phases from a specific date
  def self.all_phases_from_date(date, num_cycles = 3)
    Tracker.new.all_phases_from_date(date, num_cycles)
  end
end
