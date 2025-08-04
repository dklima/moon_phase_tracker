# frozen_string_literal: true

require_relative "moon_phase_tracker/version"
require_relative "moon_phase_tracker/client"
require_relative "moon_phase_tracker/phase"
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
end
