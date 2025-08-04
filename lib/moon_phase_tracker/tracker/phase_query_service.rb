# frozen_string_literal: true

module MoonPhaseTracker
  # Service class responsible for all phase query operations
  # Handles API communication and phase calculation orchestration
  class PhaseQueryService
    attr_reader :client

    def initialize(client)
      @client = client
    end

    # === Basic Phase Query Methods ===

    # Get major phases for a specific month
    # @param year [Integer] Year to query
    # @param month [Integer] Month to query (1-12)
    # @return [Array<Phase>] Phases occurring in the specified month
    def phases_for_month(year, month)
      year_phases = phases_for_year(year)
      filter_phases_by_month(year_phases, year, month)
    end

    # Get major phases for a specific year
    # @param year [Integer] Year to query
    # @return [Array<Phase>] All major phases in the year
    def phases_for_year(year)
      response = @client.phases_for_year(year)
      parse_api_response(response)
    end

    # Get phases starting from a specific date
    # @param date [Date] Starting date
    # @param num_phases [Integer] Number of phases to retrieve
    # @return [Array<Phase>] Phases starting from the date
    def phases_from_date(date, num_phases)
      formatted_date = format_date_for_api(date)
      response = @client.phases_from_date(formatted_date, num_phases)
      parse_api_response(response)
    end

    # === Extended Phase Methods (8-phase support) ===

    # Get all phases (major + interpolated) for a specific month
    # @param year [Integer] Year to query
    # @param month [Integer] Month to query (1-12)
    # @return [Array<Phase>] All phases in the month including interpolated
    def all_phases_for_month(year, month)
      major_phases = phases_for_month(year, month)
      all_phases = calculate_all_phases(major_phases)
      filter_phases_by_month(all_phases, year, month)
    end

    # Get all phases (major + interpolated) for a specific year
    # @param year [Integer] Year to query
    # @return [Array<Phase>] All phases in the year including interpolated
    def all_phases_for_year(year)
      major_phases = phases_for_year(year)
      calculate_all_phases(major_phases)
    end

    # Get all phases starting from a specific date for multiple cycles
    # @param date [Date] Starting date
    # @param num_cycles [Integer] Number of lunar cycles to cover
    # @return [Array<Phase>] All phases including interpolated
    def all_phases_from_date(date, num_cycles)
      # Calculate enough major phases to cover the requested cycles
      phases_needed = num_cycles * 4
      major_phases = phases_from_date(date, phases_needed)
      calculate_all_phases(major_phases)
    end

    private

    # Parse API response into Phase objects
    # @param response [Hash] API response hash
    # @return [Array<Phase>] Parsed and sorted phases
    def parse_api_response(response)
      return [] unless valid_response?(response)

      phases = response["phasedata"].map { |phase_data| Phase.new(phase_data) }
      phases.sort
    end

    # Check if API response is valid
    # @param response [Hash] Response to validate
    # @return [Boolean] True if response contains phase data
    def valid_response?(response)
      response && response["phasedata"]
    end

    # Filter phases to only include those in the specified month
    # @param phases [Array<Phase>] Phases to filter
    # @param year [Integer] Target year
    # @param month [Integer] Target month
    # @return [Array<Phase>] Filtered phases
    def filter_phases_by_month(phases, year, month)
      phases.select { |phase| phase.in_month?(year, month) }
    end

    # Format date for API consumption
    # @param date [Date] Date to format
    # @return [String] Formatted date string (YYYY-MM-DD)
    def format_date_for_api(date)
      date.strftime("%Y-%m-%d")
    end

    # Calculate all phases including interpolated ones
    # @param major_phases [Array<Phase>] Major phases to extend
    # @return [Array<Phase>] All phases including interpolated
    def calculate_all_phases(major_phases)
      calculator = PhaseCalculator.new(major_phases)
      calculator.calculate_all_phases
    end
  end
end