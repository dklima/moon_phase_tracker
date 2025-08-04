# frozen_string_literal: true

require_relative "phase/parser"
require_relative "phase/formatter"
require_relative "phase/comparator"
require_relative "phase/mapper"

module MoonPhaseTracker
  class Phase
    include Comparable

    attr_reader :name, :date, :time, :phase_type, :interpolated

    def initialize(phase_data, interpolated: false)
      @name = phase_data["phase"]
      @phase_type = Mapper.map_phase_type(@name)
      @date = Parser.build_date(phase_data)
      @time = Parser.parse_time(phase_data["time"])
      @interpolated = interpolated
    end

    def formatted_date
      Formatter.format_date(@date)
    end

    def formatted_time
      Formatter.format_time(@time)
    end

    def symbol
      Mapper.get_phase_symbol(@phase_type)
    end

    def to_s
      Formatter.format_phase_description(@name, symbol, @date, @time)
    end

    def to_h
      phase_attributes = {
        name: @name,
        phase_type: @phase_type,
        date: @date,
        time: @time,
        symbol: symbol,
        interpolated: @interpolated
      }

      Formatter.build_hash_representation(phase_attributes)
    end

    def <=>(other)
      Comparator.compare_phases(self, other)
    end

    def in_month?(year, month)
      Comparator.in_month?(@date, year, month)
    end

    def in_year?(year)
      Comparator.in_year?(@date, year)
    end
  end
end
