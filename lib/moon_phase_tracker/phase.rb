# frozen_string_literal: true

require "date"
require "time"

module MoonPhaseTracker
  class Phase
    include Comparable
    PHASE_NAMES = {
      "New Moon" => :new_moon,
      "First Quarter" => :first_quarter,
      "Full Moon" => :full_moon,
      "Last Quarter" => :last_quarter,
      # Interpolated phases
      "Waxing Crescent" => :waxing_crescent,
      "Waxing Gibbous" => :waxing_gibbous,
      "Waning Gibbous" => :waning_gibbous,
      "Waning Crescent" => :waning_crescent
    }.freeze

    PHASE_SYMBOLS = {
      new_moon: "🌑",
      waxing_crescent: "🌒",
      first_quarter: "🌓",
      waxing_gibbous: "🌔",
      full_moon: "🌕",
      waning_gibbous: "🌖",
      last_quarter: "🌗",
      waning_crescent: "🌘"
    }.freeze

    attr_reader :name, :date, :time, :phase_type, :interpolated

    def initialize(phase_data, interpolated: false)
      @name = phase_data["phase"]
      @phase_type = PHASE_NAMES[@name] || :unknown
      @date = build_date(phase_data)
      @time = parse_time(phase_data["time"])
      @interpolated = interpolated
    end

    def formatted_date
      return "Invalid date" unless @date

      @date.strftime("%Y-%m-%d")
    end

    def formatted_time
      return "Invalid time" unless @time

      @time.strftime("%H:%M")
    end

    def symbol
      PHASE_SYMBOLS[@phase_type] || "🌘"
    end

    def to_s
      "#{symbol} #{@name} - #{formatted_date} at #{formatted_time}"
    end

    def to_h
      {
        name: @name,
        phase_type: @phase_type,
        date: formatted_date,
        time: formatted_time,
        symbol: symbol,
        iso_date: @date&.iso8601,
        utc_time: @time&.utc&.iso8601,
        interpolated: @interpolated
      }
    end

    def <=>(other)
      return nil unless other.is_a?(Phase)

      date_comparison = (@date <=> other.date)
      return date_comparison unless date_comparison.zero?

      @time <=> other.time
    end

    def in_month?(year, month)
      return false unless @date

      @date.year == year && @date.month == month
    end

    def in_year?(year)
      return false unless @date

      @date.year == year
    end


    private

    def build_date(phase_data)
      year = phase_data["year"]
      month = phase_data["month"]
      day = phase_data["day"]

      return nil unless year && month && day

      Date.new(year.to_i, month.to_i, day.to_i)
    rescue Date::Error
      nil
    end

    def parse_time(time_string)
      return nil unless time_string

      Time.parse("#{time_string} UTC")
    rescue ArgumentError
      nil
    end
  end
end
