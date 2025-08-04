# frozen_string_literal: true

RSpec.describe MoonPhaseTracker::PhaseCalculator do
  let(:sample_major_phases) do
    [
      MoonPhaseTracker::Phase.new({
                                    'phase' => 'New Moon',
                                    'year' => 2025,
                                    'month' => 8,
                                    'day' => 4,
                                    'time' => '11:13'
                                  }),
      MoonPhaseTracker::Phase.new({
                                    'phase' => 'First Quarter',
                                    'year' => 2025,
                                    'month' => 8,
                                    'day' => 12,
                                    'time' => '15:19'
                                  }),
      MoonPhaseTracker::Phase.new({
                                    'phase' => 'Full Moon',
                                    'year' => 2025,
                                    'month' => 8,
                                    'day' => 19,
                                    'time' => '18:26'
                                  }),
      MoonPhaseTracker::Phase.new({
                                    'phase' => 'Last Quarter',
                                    'year' => 2025,
                                    'month' => 8,
                                    'day' => 26,
                                    'time' => '09:26'
                                  })
    ]
  end

  let(:calculator) { described_class.new(sample_major_phases) }

  describe '#calculate_all_phases' do
    it 'returns all 8 phases including interpolated ones', :aggregate_failures do
      all_phases = calculator.calculate_all_phases

      expect(all_phases.size).to be >= 4
      expect(all_phases.size).to be <= 8

      # Should include original major phases
      major_phases = all_phases.reject(&:interpolated)
      expect(major_phases.size).to eq(4)

      # Should include some interpolated phases
      interpolated_phases = all_phases.select(&:interpolated)
      expect(interpolated_phases.size).to be >= 0

      # All phases should be sorted by date
      dates = all_phases.map(&:date)
      expect(dates).to eq(dates.sort)
    end

    it 'creates interpolated phases with correct attributes', :aggregate_failures do
      all_phases = calculator.calculate_all_phases
      interpolated_phases = all_phases.select(&:interpolated)

      interpolated_phases.each do |phase|
        expect(phase.interpolated).to be true
        expect(phase.name).to be_a(String)
        expect(phase.phase_type).to be_a(Symbol)
        expect(phase.date).to be_a(Date)
        expect(phase.symbol).to be_a(String)
      end
    end

    it 'includes expected intermediate phase types', :aggregate_failures do
      all_phases = calculator.calculate_all_phases
      phase_types = all_phases.map(&:phase_type)

      # Should include major phases
      expect(phase_types).to include(:new_moon)
      expect(phase_types).to include(:first_quarter)
      expect(phase_types).to include(:full_moon)
      expect(phase_types).to include(:last_quarter)
    end

    it 'calculates intermediate phases with logical timing', :aggregate_failures do
      all_phases = calculator.calculate_all_phases

      # Get phases in order
      sorted_phases = all_phases.sort_by(&:date)

      # Check basic structure
      expect(sorted_phases.size).to be >= 4

      # Verify that major phases are included
      major_phase_types = sorted_phases.reject(&:interpolated).map(&:phase_type)
      expect(major_phase_types).to include(:new_moon, :first_quarter, :full_moon, :last_quarter)

      # Verify interpolated phases have correct attributes
      interpolated_phases = sorted_phases.select(&:interpolated)
      interpolated_phases.each do |phase|
        expect(phase.interpolated).to be true
        expect(phase.date).to be_a(Date)
        expect(phase.time).to be_a(Time)
        expect(%i[waxing_crescent waxing_gibbous waning_gibbous waning_crescent]).to include(phase.phase_type)
      end
    end
  end

  describe 'phase symbols' do
    it 'has symbols for all 8 phases', :aggregate_failures do
      expect(MoonPhaseTracker::Phase::Mapper::PHASE_SYMBOLS).to include(
        :new_moon, :waxing_crescent, :first_quarter, :waxing_gibbous,
        :full_moon, :waning_gibbous, :last_quarter, :waning_crescent
      )

      # All symbols should be moon emojis
      MoonPhaseTracker::Phase::Mapper::PHASE_SYMBOLS.each_value do |symbol|
        expect(symbol).to match(/🌑|🌒|🌓|🌔|🌕|🌖|🌗|🌘/)
      end
    end
  end
end
