# frozen_string_literal: true

module MoonPhaseTracker
  class Phase
    class Mapper
      PHASE_NAMES = {
        "New Moon" => :new_moon,
        "First Quarter" => :first_quarter,
        "Full Moon" => :full_moon,
        "Last Quarter" => :last_quarter,
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

      DEFAULT_PHASE_TYPE = :unknown
      DEFAULT_SYMBOL = "🌘"

      def self.map_phase_type(phase_name)
        PHASE_NAMES[phase_name] || DEFAULT_PHASE_TYPE
      end

      def self.get_phase_symbol(phase_type)
        PHASE_SYMBOLS[phase_type] || DEFAULT_SYMBOL
      end

      def self.available_phase_names
        PHASE_NAMES.keys
      end

      def self.available_phase_types
        PHASE_NAMES.values
      end

      def self.valid_phase_name?(phase_name)
        PHASE_NAMES.key?(phase_name)
      end

      def self.valid_phase_type?(phase_type)
        PHASE_SYMBOLS.key?(phase_type)
      end
    end
  end
end
