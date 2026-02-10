# frozen_string_literal: true

RSpec.describe MoonPhaseTracker do
  it 'has a version number' do
    expect(MoonPhaseTracker::VERSION).not_to be nil
  end

  describe '.phases_for_month' do
    it 'returns phases for a specific month', :aggregate_failures do
      allow_any_instance_of(MoonPhaseTracker::Client).to receive(:phases_for_year)
        .and_return(sample_year_response)

      phases = MoonPhaseTracker.phases_for_month(2025, 8)

      expect(phases).to be_an(Array)
      expect(phases).not_to be_empty
      expect(phases.first).to be_a(MoonPhaseTracker::Phase)
      expect(phases.all? { |p| p.in_month?(2025, 8) }).to be true
    end
  end

  describe '.phases_for_year' do
    it 'returns all phases for a year', :aggregate_failures do
      allow_any_instance_of(MoonPhaseTracker::Client).to receive(:phases_for_year)
        .and_return(sample_year_response)

      phases = MoonPhaseTracker.phases_for_year(2025)

      expect(phases).to be_an(Array)
      expect(phases.size).to be >= 4
      expect(phases.first).to be_a(MoonPhaseTracker::Phase)
      expect(phases.all? { |p| p.in_year?(2025) }).to be true
    end
  end

  describe '.phases_from_date' do
    it 'returns phases from specific date', :aggregate_failures do
      allow_any_instance_of(MoonPhaseTracker::Client).to receive(:phases_from_date)
        .and_return(sample_phases_response)

      phases = MoonPhaseTracker.phases_from_date('2025-08-01', 4)

      expect(phases).to be_an(Array)
      expect(phases.size).to eq(4)
      expect(phases.first).to be_a(MoonPhaseTracker::Phase)
    end
  end

  describe '.all_phases_for_month' do
    it 'returns all 8 phases for a specific month', :aggregate_failures do
      allow_any_instance_of(MoonPhaseTracker::Client).to receive(:phases_for_year)
        .and_return(sample_year_response)

      phases = MoonPhaseTracker.all_phases_for_month(2025, 8)

      expect(phases).to be_an(Array)
      expect(phases).not_to be_empty
      expect(phases.first).to be_a(MoonPhaseTracker::Phase)

      # Should include both major and potentially interpolated phases
      major_phases = phases.reject(&:interpolated)
      expect(major_phases.size).to be >= 1
    end
  end

  describe '.all_phases_for_year' do
    it 'returns all phases for a year including interpolated', :aggregate_failures do
      allow_any_instance_of(MoonPhaseTracker::Client).to receive(:phases_for_year)
        .and_return(sample_year_response)

      phases = MoonPhaseTracker.all_phases_for_year(2025)

      expect(phases).to be_an(Array)
      expect(phases.size).to be >= 4
      expect(phases.first).to be_a(MoonPhaseTracker::Phase)

      # Should include both major and interpolated phases
      major_phases = phases.reject(&:interpolated)
      interpolated_phases = phases.select(&:interpolated)

      expect(major_phases.size).to eq(4)
      expect(interpolated_phases.size).to be >= 0
    end
  end

  describe '.phase_at' do
    it 'returns a Phase for a given date', :aggregate_failures do
      phase = MoonPhaseTracker.phase_at(Date.new(2025, 6, 8))

      expect(phase).to be_a(MoonPhaseTracker::Phase)
      expect(phase.source).to eq(:calculated)
      expect(phase.illumination).to be_a(Float)
      expect(phase.lunar_age).to be_a(Float)
      expect(phase.date).to eq(Date.new(2025, 6, 8))
    end
  end

  describe '.illumination' do
    it 'returns a percentage between 0 and 100', :aggregate_failures do
      illum = MoonPhaseTracker.illumination(Date.new(2025, 6, 8))

      expect(illum).to be_a(Float)
      expect(illum).to be >= 0.0
      expect(illum).to be <= 100.0
    end
  end

  describe '.current_phase' do
    it 'returns a Phase for the current moment', :aggregate_failures do
      phase = MoonPhaseTracker.current_phase

      expect(phase).to be_a(MoonPhaseTracker::Phase)
      expect(phase.source).to eq(:calculated)
      expect(phase.date).to eq(Time.now.utc.to_date)
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
end
