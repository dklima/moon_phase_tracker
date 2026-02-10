# frozen_string_literal: true

RSpec.describe MoonPhaseTracker::Tracker do
  let(:tracker) { described_class.new }
  let(:mock_client) { instance_double(MoonPhaseTracker::Client) }

  before do
    allow(MoonPhaseTracker::Client).to receive(:new).and_return(mock_client)
  end

  describe '#phases_for_month' do
    let(:sample_response) { sample_year_response }

    before do
      allow(mock_client).to receive(:phases_for_year).and_return(sample_response)
    end

    it 'returns phases for specific month', :aggregate_failures do
      phases = tracker.phases_for_month(2025, 8)

      expect(phases).to be_an(Array)
      expect(phases.size).to eq(4)
      expect(phases.all? { |p| p.in_month?(2025, 8) }).to be true
    end

    it 'raises error for invalid month', :aggregate_failures do
      expect { tracker.phases_for_month(2025, 0) }.to raise_error(MoonPhaseTracker::InvalidDateError)
      expect { tracker.phases_for_month(2025, 13) }.to raise_error(MoonPhaseTracker::InvalidDateError)
    end
  end

  describe '#phases_for_year' do
    let(:sample_response) { sample_year_response }

    before do
      allow(mock_client).to receive(:phases_for_year).and_return(sample_response)
    end

    it 'returns all phases for year', :aggregate_failures do
      phases = tracker.phases_for_year(2025)

      expect(phases).to be_an(Array)
      expect(phases.size).to eq(4)
      expect(phases.all? { |p| p.in_year?(2025) }).to be true
    end

    it 'raises error for invalid year', :aggregate_failures do
      expect { tracker.phases_for_year(1600) }.to raise_error(MoonPhaseTracker::InvalidDateError)
      expect { tracker.phases_for_year(3000) }.to raise_error(MoonPhaseTracker::InvalidDateError)
    end
  end

  describe '#phases_from_date' do
    let(:sample_response) { sample_phases_response }

    before do
      allow(mock_client).to receive(:phases_from_date).and_return(sample_response)
    end

    it 'returns phases from specific date', :aggregate_failures do
      phases = tracker.phases_from_date('2025-08-01', 4)

      expect(phases).to be_an(Array)
      expect(phases.size).to eq(4)
      expect(mock_client).to have_received(:phases_from_date).with('2025-08-01', 4)
    end

    it 'accepts Date objects', :aggregate_failures do
      date = Date.new(2025, 8, 1)
      tracker.phases_from_date(date, 2)

      expect(mock_client).to have_received(:phases_from_date).with('2025-08-01', 2)
    end

    it 'raises error for invalid date format' do
      expect { tracker.phases_from_date('invalid-date') }.to raise_error(MoonPhaseTracker::InvalidDateError)
    end
  end

  describe '#format_phases' do
    let(:sample_response) { sample_phases_response }
    let(:phases) do
      sample_response['phasedata'].map { |data| MoonPhaseTracker::Phase.new(data) }
    end

    it 'formats phases with title', :aggregate_failures do
      result = tracker.format_phases(phases, 'Fases de Agosto 2025')

      expect(result).to include('Fases de Agosto 2025')
      expect(result).to include('🌑 New Moon')
      expect(result).to include('Total: 4 phase(s)')
    end

    it 'returns message for empty phases' do
      result = tracker.format_phases([])
      expect(result).to eq('No phases found.')
    end
  end

  describe '#phase_at' do
    it 'returns a calculated Phase for a given date', :aggregate_failures do
      phase = tracker.phase_at("2025-06-11")

      expect(phase).to be_a(MoonPhaseTracker::Phase)
      expect(phase.source).to eq(:calculated)
      expect(phase.illumination).to be_a(Float)
      expect(phase.lunar_age).to be_a(Float)
    end

    it 'accepts Date objects' do
      phase = tracker.phase_at(Date.new(2025, 1, 15))

      expect(phase).to be_a(MoonPhaseTracker::Phase)
    end

    it 'raises error for invalid date format' do
      expect { tracker.phase_at('invalid-date') }.to raise_error(MoonPhaseTracker::InvalidDateError)
    end
  end

  describe '#illumination' do
    it 'returns a Float between 0 and 100' do
      illum = tracker.illumination("2025-06-11")

      expect(illum).to be_a(Float)
      expect(illum).to be_between(0, 100)
    end

    it 'raises error for invalid date format' do
      expect { tracker.illumination('invalid-date') }.to raise_error(MoonPhaseTracker::InvalidDateError)
    end
  end

  describe '#current_phase' do
    it 'returns a calculated Phase for the current time', :aggregate_failures do
      frozen_time = Time.utc(2025, 1, 15, 12, 0, 0)
      allow(Time).to receive(:now).and_return(frozen_time)

      phase = tracker.current_phase

      expect(phase).to be_a(MoonPhaseTracker::Phase)
      expect(phase.source).to eq(:calculated)
      expect(phase.illumination).to be_a(Float)
    end
  end

  describe '.month_name' do
    it 'returns correct English month names', :aggregate_failures do
      expect(described_class.month_name(1)).to eq('January')
      expect(described_class.month_name(8)).to eq('August')
      expect(described_class.month_name(12)).to eq('December')
    end
  end

  private

  def sample_year_response
    {
      'phasedata' => [
        {
          'phase' => 'New Moon',
          'year' => 2025,
          'month' => 8,
          'day' => 4,
          'time' => '11:13'
        },
        {
          'phase' => 'First Quarter',
          'year' => 2025,
          'month' => 8,
          'day' => 12,
          'time' => '15:19'
        },
        {
          'phase' => 'Full Moon',
          'year' => 2025,
          'month' => 8,
          'day' => 19,
          'time' => '18:26'
        },
        {
          'phase' => 'Last Quarter',
          'year' => 2025,
          'month' => 8,
          'day' => 26,
          'time' => '09:26'
        }
      ]
    }
  end

  def sample_phases_response
    sample_year_response
  end
end
