# frozen_string_literal: true

RSpec.describe MoonPhaseTracker do
  it "has a version number" do
    expect(MoonPhaseTracker::VERSION).not_to be nil
  end

  describe ".phases_for_month" do
    it "returns phases for a specific month", :aggregate_failures do
      allow_any_instance_of(MoonPhaseTracker::Client).to receive(:phases_for_year)
        .and_return(sample_year_response)
      
      phases = MoonPhaseTracker.phases_for_month(2025, 8)
      
      expect(phases).to be_an(Array)
      expect(phases).not_to be_empty
      expect(phases.first).to be_a(MoonPhaseTracker::Phase)
      expect(phases.all? { |p| p.in_month?(2025, 8) }).to be true
    end
  end

  describe ".phases_for_year" do
    it "returns all phases for a year", :aggregate_failures do
      allow_any_instance_of(MoonPhaseTracker::Client).to receive(:phases_for_year)
        .and_return(sample_year_response)
      
      phases = MoonPhaseTracker.phases_for_year(2025)
      
      expect(phases).to be_an(Array)
      expect(phases.size).to be >= 4
      expect(phases.first).to be_a(MoonPhaseTracker::Phase)
      expect(phases.all? { |p| p.in_year?(2025) }).to be true
    end
  end

  describe ".phases_from_date" do
    it "returns phases from specific date", :aggregate_failures do
      allow_any_instance_of(MoonPhaseTracker::Client).to receive(:phases_from_date)
        .and_return(sample_phases_response)
      
      phases = MoonPhaseTracker.phases_from_date("2025-08-01", 4)
      
      expect(phases).to be_an(Array)
      expect(phases.size).to eq(4)
      expect(phases.first).to be_a(MoonPhaseTracker::Phase)
    end
  end

  private

  def sample_year_response
    {
      "phasedata" => [
        {
          "phase" => "New Moon",
          "year" => 2025,
          "month" => 8,
          "day" => 4,
          "time" => "11:13"
        },
        {
          "phase" => "First Quarter",
          "year" => 2025,
          "month" => 8,
          "day" => 12,
          "time" => "15:19"
        },
        {
          "phase" => "Full Moon",
          "year" => 2025,
          "month" => 8,
          "day" => 19,
          "time" => "18:26"
        },
        {
          "phase" => "Last Quarter",
          "year" => 2025,
          "month" => 8,
          "day" => 26,
          "time" => "09:26"
        }
      ]
    }
  end

  def sample_phases_response
    {
      "phasedata" => [
        {
          "phase" => "New Moon",
          "year" => 2025,
          "month" => 8,
          "day" => 4,
          "time" => "11:13"
        },
        {
          "phase" => "First Quarter",
          "year" => 2025,
          "month" => 8,
          "day" => 12,
          "time" => "15:19"
        },
        {
          "phase" => "Full Moon",
          "year" => 2025,
          "month" => 8,
          "day" => 19,
          "time" => "18:26"
        },
        {
          "phase" => "Last Quarter",
          "year" => 2025,
          "month" => 8,
          "day" => 26,
          "time" => "09:26"
        }
      ]
    }
  end
end
