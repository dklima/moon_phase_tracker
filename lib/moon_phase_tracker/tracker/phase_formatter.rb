# frozen_string_literal: true

module MoonPhaseTracker
  # Service class responsible for formatting phase output
  # Handles display logic and phase statistics
  class PhaseFormatter
    # Format phases into a readable string output
    # @param phases [Array<Phase>] Phases to format
    # @param title [String, nil] Optional title for the output
    # @return [String] Formatted output string
    def format(phases, title = nil)
      return "No phases found." if phases.empty?

      build_formatted_output(phases, title)
    end

    private

    # Build the complete formatted output
    # @param phases [Array<Phase>] Phases to format
    # @param title [String, nil] Optional title
    # @return [String] Complete formatted string
    def build_formatted_output(phases, title)
      output_lines = []
      
      add_title_section(output_lines, title)
      add_phases_section(output_lines, phases)
      add_statistics_section(output_lines, phases)
      
      output_lines.join("\n")
    end

    # Add title section to output if provided
    # @param output_lines [Array<String>] Output lines array
    # @param title [String, nil] Title to add
    def add_title_section(output_lines, title)
      return unless title

      output_lines << title
      output_lines << "=" * title.length
      output_lines << ""
    end

    # Add formatted phases section
    # @param output_lines [Array<String>] Output lines array
    # @param phases [Array<Phase>] Phases to format
    def add_phases_section(output_lines, phases)
      phases.each do |phase|
        prefix = phase.interpolated ? "~" : " "
        output_lines << "#{prefix}#{phase}"
      end
      
      output_lines << ""
    end

    # Add statistics section with phase counts
    # @param output_lines [Array<String>] Output lines array
    # @param phases [Array<Phase>] Phases to analyze
    def add_statistics_section(output_lines, phases)
      phase_stats = calculate_phase_statistics(phases)
      
      if phase_stats[:interpolated_count].positive?
        add_detailed_statistics(output_lines, phase_stats)
        output_lines << "~ indicates interpolated phases"
      else
        output_lines << "Total: #{phase_stats[:total_count]} phase(s)"
      end
    end

    # Calculate phase statistics
    # @param phases [Array<Phase>] Phases to analyze
    # @return [Hash] Statistics hash with counts
    def calculate_phase_statistics(phases)
      {
        total_count: phases.size,
        major_count: phases.count { |phase| !phase.interpolated },
        interpolated_count: phases.count(&:interpolated)
      }
    end

    # Add detailed statistics for mixed phase types
    # @param output_lines [Array<String>] Output lines array
    # @param stats [Hash] Phase statistics
    def add_detailed_statistics(output_lines, stats)
      output_lines << "Total: #{stats[:total_count]} phase(s) " \
                      "(#{stats[:major_count]} major, #{stats[:interpolated_count]} interpolated)"
    end
  end
end