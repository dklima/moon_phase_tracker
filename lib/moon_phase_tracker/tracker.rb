# frozen_string_literal: true

require "date"
require_relative "tracker/phase_query_service"
require_relative "tracker/phase_formatter"
require_relative "tracker/date_parser"
require_relative "tracker/validators"

module MoonPhaseTracker
  class Tracker
    include Validators

    attr_reader :client, :query_service, :formatter, :date_parser

    def initialize(rate_limiter: nil)
      @client = Client.new(rate_limiter: rate_limiter)
      @query_service = PhaseQueryService.new(@client)
      @formatter = PhaseFormatter.new
      @date_parser = DateParser.new
    end

    def rate_limit_info
      @client.rate_limit_info
    end

    def phases_for_month(year, month)
      validate_month!(year, month)
      @query_service.phases_for_month(year, month)
    end

    def phases_for_year(year)
      validate_year!(year)
      @query_service.phases_for_year(year)
    end

    def phases_from_date(date, num_phases = 12)
      parsed_date = @date_parser.parse(date)
      validate_num_phases!(num_phases)
      @query_service.phases_from_date(parsed_date, num_phases)
    end

    def next_phase
      phases_from_date(Date.today, 1).first
    end

    def phase_at(date)
      parsed = @date_parser.parse(date)
      calculator.phase_at(parsed)
    end

    def illumination(date)
      parsed = @date_parser.parse(date)
      calculator.illumination(parsed)
    end

    def current_phase
      calculator.phase_at(Time.now.utc)
    end

    def current_month_phases
      today = Date.today
      phases_for_month(today.year, today.month)
    end

    def current_year_phases
      phases_for_year(Date.today.year)
    end

    def all_phases_for_month(year, month)
      validate_month!(year, month)
      @query_service.all_phases_for_month(year, month)
    end

    def all_phases_for_year(year)
      validate_year!(year)
      @query_service.all_phases_for_year(year)
    end

    def all_phases_from_date(date, num_cycles = 3)
      parsed_date = @date_parser.parse(date)
      @query_service.all_phases_from_date(parsed_date, num_cycles)
    end

    def format_phases(phases, title = nil)
      @formatter.format(phases, title)
    end

    def self.month_name(month)
      MONTH_NAMES[month - 1]
    end

    private

    def calculator
      @calculator ||= LunarCalculator.new
    end

    MONTH_NAMES = %w[
      January February March April May June
      July August September October November December
    ].freeze
  end
end
