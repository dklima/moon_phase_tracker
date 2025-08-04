# frozen_string_literal: true

module MoonPhaseTracker
  class PhaseQueryService
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def phases_for_month(year, month)
      year_phases = phases_for_year(year)
      filter_phases_by_month(year_phases, year, month)
    end

    def phases_for_year(year)
      response = @client.phases_for_year(year)
      parse_api_response(response)
    end

    def phases_from_date(date, num_phases)
      formatted_date = format_date_for_api(date)
      response = @client.phases_from_date(formatted_date, num_phases)
      parse_api_response(response)
    end

    def all_phases_for_month(year, month)
      major_phases = phases_for_month(year, month)
      all_phases = calculate_all_phases(major_phases)
      filter_phases_by_month(all_phases, year, month)
    end

    def all_phases_for_year(year)
      major_phases = phases_for_year(year)
      calculate_all_phases(major_phases)
    end

    def all_phases_from_date(date, num_cycles)
      # Calculate enough major phases to cover the requested cycles
      phases_needed = num_cycles * 4
      major_phases = phases_from_date(date, phases_needed)
      calculate_all_phases(major_phases)
    end

    private

    def parse_api_response(response)
      return [] unless valid_response?(response)

      phases = response["phasedata"].map { |phase_data| Phase.new(phase_data) }
      phases.sort
    end

    def valid_response?(response)
      response && response["phasedata"]
    end

    def filter_phases_by_month(phases, year, month)
      phases.select { |phase| phase.in_month?(year, month) }
    end

    def format_date_for_api(date)
      date.strftime("%Y-%m-%d")
    end

    def calculate_all_phases(major_phases)
      calculator = PhaseCalculator.new(major_phases)
      calculator.calculate_all_phases
    end
  end
end
