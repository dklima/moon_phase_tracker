# frozen_string_literal: true

module MoonPhaseTracker
  class PhaseFormatter
    def format(phases, title = nil)
      return "No phases found." if phases.empty?

      build_formatted_output(phases, title)
    end

    private

    def build_formatted_output(phases, title)
      output_lines = []

      add_title_section(output_lines, title)
      add_phases_section(output_lines, phases)
      add_statistics_section(output_lines, phases)

      output_lines.join("\n")
    end

    def add_title_section(output_lines, title)
      return unless title

      output_lines << title
      output_lines << "=" * title.length
      output_lines << ""
    end

    def add_phases_section(output_lines, phases)
      phases.each do |phase|
        prefix = phase.interpolated ? "~" : " "
        output_lines << "#{prefix}#{phase}"
      end

      output_lines << ""
    end

    def add_statistics_section(output_lines, phases)
      phase_stats = calculate_phase_statistics(phases)

      if phase_stats[:interpolated_count].positive?
        add_detailed_statistics(output_lines, phase_stats)
        output_lines << "~ indicates interpolated phases"
      else
        output_lines << "Total: #{phase_stats[:total_count]} phase(s)"
      end
    end

    def calculate_phase_statistics(phases)
      {
        total_count: phases.size,
        major_count: phases.count { |phase| !phase.interpolated },
        interpolated_count: phases.count(&:interpolated)
      }
    end

    def add_detailed_statistics(output_lines, stats)
      output_lines << "Total: #{stats[:total_count]} phase(s) " \
                      "(#{stats[:major_count]} major, #{stats[:interpolated_count]} interpolated)"
    end
  end
end
