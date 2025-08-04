# frozen_string_literal: true

require 'date'

module MoonPhaseTracker
  class Tracker
    def initialize
      @client = Client.new
    end

    def phases_for_month(year, month)
      validate_month!(year, month)

      year_phases = phases_for_year(year)
      year_phases.select { |phase| phase.in_month?(year, month) }
    end

    def phases_for_year(year)
      validate_year!(year)

      response = @client.phases_for_year(year)
      parse_phases(response)
    end

    def phases_from_date(date, num_phases = 12)
      date_obj = parse_date(date)
      validate_num_phases!(num_phases)

      formatted_date = date_obj.strftime('%Y-%m-%d')
      response = @client.phases_from_date(formatted_date, num_phases)
      parse_phases(response)
    end

    def next_phase
      phases_from_date(Date.today, 1).first
    end

    def current_month_phases
      today = Date.today
      phases_for_month(today.year, today.month)
    end

    def current_year_phases
      phases_for_year(Date.today.year)
    end

    # Get all 8 phases (4 major + 4 intermediate) for a month
    def all_phases_for_month(year, month)
      major_phases = phases_for_month(year, month)
      calculator = PhaseCalculator.new(major_phases)
      all_phases = calculator.calculate_all_phases

      # Filter to only phases in the requested month
      all_phases.select { |phase| phase.in_month?(year, month) }
    end

    # Get all 8 phases (4 major + 4 intermediate) for a year
    def all_phases_for_year(year)
      major_phases = phases_for_year(year)
      calculator = PhaseCalculator.new(major_phases)
      calculator.calculate_all_phases
    end

    # Get all 8 phases from a specific date
    def all_phases_from_date(date, num_cycles = 3)
      # Get enough major phases to cover the requested cycles
      major_phases = phases_from_date(date, num_cycles * 4)
      calculator = PhaseCalculator.new(major_phases)
      calculator.calculate_all_phases
    end

    def format_phases(phases, title = nil)
      return 'No phases found.' if phases.empty?

      output = []
      output << title if title
      output << '=' * title.length if title
      output << ''

      phases.each do |phase|
        prefix = phase.interpolated ? '~' : ' '
        output << "#{prefix}#{phase}"
      end

      output << ''
      major_count = phases.count { |p| !p.interpolated }
      interpolated_count = phases.count(&:interpolated)

      if interpolated_count.positive?
        output << "Total: #{phases.size} phase(s) (#{major_count} major, #{interpolated_count} interpolated)"
        output << '~ indicates interpolated phases'
      else
        output << "Total: #{phases.size} phase(s)"
      end

      output.join("\n")
    end

    def self.month_name(month)
      months = %w[
        January February March April May June
        July August September October November December
      ]

      months[month - 1]
    end

    private

    def parse_phases(response)
      return [] unless response && response['phasedata']

      phases = response['phasedata'].map { |phase_data| Phase.new(phase_data) }
      phases.sort
    end

    def parse_date(date)
      case date
      when String
        Date.parse(date)
      when Date
        date
      when Time
        date.to_date
      else
        raise InvalidDateError, 'Invalid date format'
      end
    rescue Date::Error
      raise InvalidDateError, "Invalid date: #{date}"
    end

    def validate_year!(year)
      current_year = Date.today.year

      return if year.is_a?(Integer) && year.between?(1700, current_year + 10)

      raise InvalidDateError, "Year must be between 1700 and #{current_year + 10}"
    end

    def validate_month!(year, month)
      validate_year!(year)

      return if month.is_a?(Integer) && month.between?(1, 12)

      raise InvalidDateError, 'Month must be between 1 and 12'
    end

    def validate_num_phases!(num_phases)
      return if num_phases.is_a?(Integer) && num_phases.between?(1, 99)

      raise InvalidDateError, 'Number of phases must be between 1 and 99'
    end
  end
end
