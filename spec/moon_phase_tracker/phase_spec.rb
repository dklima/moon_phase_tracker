# frozen_string_literal: true

RSpec.describe MoonPhaseTracker::Phase do
  let(:phase_data) do
    {
      'phase' => 'Full Moon',
      'year' => 2025,
      'month' => 8,
      'day' => 19,
      'time' => '18:26'
    }
  end

  let(:phase) { described_class.new(phase_data) }

  describe '#initialize' do
    it 'creates phase with correct attributes', :aggregate_failures do
      expect(phase.name).to eq('Full Moon')
      expect(phase.phase_type).to eq(:full_moon)
      expect(phase.formatted_date).to eq('2025-08-19')
      expect(phase.formatted_time).to eq('18:26')
    end
  end

  describe '#symbol' do
    it 'returns correct symbol for each phase type', :aggregate_failures do
      new_moon = described_class.new(phase_data.merge('phase' => 'New Moon'))
      waxing_crescent = described_class.new(phase_data.merge('phase' => 'Waxing Crescent'))
      first_quarter = described_class.new(phase_data.merge('phase' => 'First Quarter'))
      waxing_gibbous = described_class.new(phase_data.merge('phase' => 'Waxing Gibbous'))
      full_moon = described_class.new(phase_data.merge('phase' => 'Full Moon'))
      waning_gibbous = described_class.new(phase_data.merge('phase' => 'Waning Gibbous'))
      last_quarter = described_class.new(phase_data.merge('phase' => 'Last Quarter'))
      waning_crescent = described_class.new(phase_data.merge('phase' => 'Waning Crescent'))

      expect(new_moon.symbol).to eq('🌑')
      expect(waxing_crescent.symbol).to eq('🌒')
      expect(first_quarter.symbol).to eq('🌓')
      expect(waxing_gibbous.symbol).to eq('🌔')
      expect(full_moon.symbol).to eq('🌕')
      expect(waning_gibbous.symbol).to eq('🌖')
      expect(last_quarter.symbol).to eq('🌗')
      expect(waning_crescent.symbol).to eq('🌘')
    end
  end

  describe '#to_s' do
    it 'returns formatted string representation' do
      expected = '🌕 Full Moon - 2025-08-19 at 18:26'
      expect(phase.to_s).to eq(expected)
    end
  end

  describe '#to_h' do
    it 'returns detailed hash representation', :aggregate_failures do
      hash = phase.to_h

      expect(hash[:name]).to eq('Full Moon')
      expect(hash[:phase_type]).to eq(:full_moon)
      expect(hash[:date]).to eq('2025-08-19')
      expect(hash[:time]).to eq('18:26')
      expect(hash[:symbol]).to eq('🌕')
      expect(hash[:iso_date]).to eq('2025-08-19')
      expect(hash[:interpolated]).to be false
    end
  end

  describe '#time date anchoring' do
    it 'anchors time to the phase date, not today', :aggregate_failures do
      hash = phase.to_h

      expect(hash[:utc_time]).to eq("2025-08-19T18:26:00Z")
      expect(phase.time.year).to eq(2025)
      expect(phase.time.month).to eq(8)
      expect(phase.time.day).to eq(19)
    end
  end

  describe '.from_calculation' do
    let(:calculated_phase) do
      described_class.from_calculation(
        name: "Waxing Gibbous",
        date: Date.new(2025, 6, 8),
        time: "14:30",
        illumination: 78.5,
        lunar_age: 12.3
      )
    end

    it 'creates phase with calculated attributes', :aggregate_failures do
      expect(calculated_phase.name).to eq("Waxing Gibbous")
      expect(calculated_phase.phase_type).to eq(:waxing_gibbous)
      expect(calculated_phase.source).to eq(:calculated)
      expect(calculated_phase.illumination).to eq(78.5)
      expect(calculated_phase.lunar_age).to eq(12.3)
    end

    it 'handles edge illumination values', :aggregate_failures do
      edge_phase = described_class.from_calculation(
        name: "New Moon", date: Date.new(2025, 1, 6),
        time: "18:14", illumination: 0.0, lunar_age: 0.0
      )

      expect(edge_phase.illumination).to eq(0.0)
      expect(edge_phase.lunar_age).to eq(0.0)
      expect(edge_phase.interpolated).to be false
    end

    it 'includes new attributes in to_h', :aggregate_failures do
      hash = calculated_phase.to_h

      expect(hash[:source]).to eq(:calculated)
      expect(hash[:illumination]).to eq(78.5)
      expect(hash[:lunar_age]).to eq(12.3)
    end
  end

  describe 'backward compatibility' do
    it 'defaults to source: :api, nil illumination and lunar_age', :aggregate_failures do
      expect(phase.source).to eq(:api)
      expect(phase.illumination).to be_nil
      expect(phase.lunar_age).to be_nil
    end

    it 'includes all keys in to_h', :aggregate_failures do
      hash = phase.to_h

      expect(hash).to have_key(:source)
      expect(hash).to have_key(:illumination)
      expect(hash).to have_key(:lunar_age)
      expect(hash[:source]).to eq(:api)
      expect(hash[:illumination]).to be_nil
      expect(hash[:lunar_age]).to be_nil
    end
  end

  describe '#in_month?' do
    it 'correctly identifies if phase is in specific month', :aggregate_failures do
      expect(phase.in_month?(2025, 8)).to be true
      expect(phase.in_month?(2025, 7)).to be false
      expect(phase.in_month?(2024, 8)).to be false
    end
  end

  describe '#in_year?' do
    it 'correctly identifies if phase is in specific year', :aggregate_failures do
      expect(phase.in_year?(2025)).to be true
      expect(phase.in_year?(2024)).to be false
    end
  end

  describe '#<=>' do
    let(:earlier_phase) do
      described_class.new(phase_data.merge('day' => 15))
    end

    let(:later_phase) do
      described_class.new(phase_data.merge('day' => 25))
    end

    it 'compares phases by date correctly', :aggregate_failures do
      expect(earlier_phase < phase).to be true
      expect(phase < later_phase).to be true
      expect(phase <=> phase).to eq(0)
    end
  end
end
