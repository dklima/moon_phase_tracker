# frozen_string_literal: true

RSpec.describe MoonPhaseTracker::LunarCalculator do
  let(:calculator) { described_class.new }

  describe "#phase_at" do
    it "returns New Moon shortly after the known epoch", :aggregate_failures do
      phase = calculator.phase_at(Time.utc(2000, 1, 7, 6, 0))

      expect(phase).to be_a(MoonPhaseTracker::Phase)
      expect(phase.name).to eq("New Moon")
      expect(phase.source).to eq(:calculated)
      expect(phase.illumination).to be_within(2).of(0)
      expect(phase.lunar_age).to be_within(1).of(0.5)
    end

    it "returns Full Moon near a known Full Moon date", :aggregate_failures do
      phase = calculator.phase_at(Time.utc(2025, 6, 11, 7, 44))

      expect(phase.name).to eq("Full Moon")
      expect(phase.illumination).to be_within(5).of(100)
    end

    it "returns approximately 50% illumination at First Quarter", :aggregate_failures do
      phase = calculator.phase_at(Time.utc(2025, 6, 3, 3, 41))

      expect(phase.illumination).to be_within(10).of(50)
    end

    it "accepts Date input" do
      phase = calculator.phase_at(Date.new(2025, 1, 15))

      expect(phase).to be_a(MoonPhaseTracker::Phase)
      expect(phase.source).to eq(:calculated)
    end

    it "accepts DateTime input" do
      phase = calculator.phase_at(DateTime.new(2025, 1, 15, 12, 0, 0))

      expect(phase).to be_a(MoonPhaseTracker::Phase)
    end

    it "accepts String input" do
      phase = calculator.phase_at("2025-01-15")

      expect(phase).to be_a(MoonPhaseTracker::Phase)
    end

    it "raises ArgumentError for invalid types" do
      expect { calculator.phase_at(12345) }.to raise_error(ArgumentError, /Expected Date, Time, DateTime, or String/)
    end

    it "raises ArgumentError for unparseable strings" do
      expect { calculator.phase_at("not-a-date") }.to raise_error(ArgumentError, /Cannot parse date string/)
    end

    it "handles far past dates without crashing" do
      phase = calculator.phase_at(Date.new(1800, 6, 15))

      expect(phase).to be_a(MoonPhaseTracker::Phase)
      expect(phase.illumination).to be_between(0, 100)
    end

    it "handles far future dates without crashing" do
      phase = calculator.phase_at(Date.new(2100, 6, 15))

      expect(phase).to be_a(MoonPhaseTracker::Phase)
      expect(phase.illumination).to be_between(0, 100)
    end
  end

  describe "#illumination" do
    it "returns near 0% shortly after New Moon epoch" do
      illum = calculator.illumination(Time.utc(2000, 1, 7, 6, 0))

      expect(illum).to be_within(2).of(0)
    end

    it "returns near 100% at a known Full Moon" do
      illum = calculator.illumination(Time.utc(2025, 6, 11, 7, 44))

      expect(illum).to be_within(5).of(100)
    end

    it "returns a Float between 0 and 100" do
      illum = calculator.illumination(Date.today)

      expect(illum).to be_a(Float)
      expect(illum).to be_between(0, 100)
    end
  end

  describe "#lunar_age" do
    it "returns near 0 shortly after New Moon epoch" do
      age = calculator.lunar_age(Time.utc(2000, 1, 7, 6, 0))

      expect(age).to be_within(1).of(0.5)
    end

    it "returns approximately half a synodic month at Full Moon" do
      age = calculator.lunar_age(Time.utc(2025, 6, 11, 7, 44))
      half_cycle = described_class::SYNODIC_MONTH / 2.0

      expect(age).to be_within(1.5).of(half_cycle)
    end

    it "returns a value within one synodic month" do
      age = calculator.lunar_age(Date.today)

      expect(age).to be >= 0
      expect(age).to be < described_class::SYNODIC_MONTH
    end
  end

  describe "#cycle_position" do
    it "returns near 0.0 shortly after New Moon epoch" do
      pos = calculator.cycle_position(Time.utc(2000, 1, 7, 6, 0))

      expect(pos).to be_within(0.02).of(0.02)
    end

    it "returns near 0.5 at Full Moon" do
      pos = calculator.cycle_position(Time.utc(2025, 6, 11, 7, 44))

      expect(pos).to be_within(0.05).of(0.5)
    end

    it "returns a value between 0.0 and 1.0" do
      pos = calculator.cycle_position(Date.today)

      expect(pos).to be >= 0.0
      expect(pos).to be < 1.0
    end
  end

  describe "phase boundary classification" do
    it "classifies fraction at exactly 0.0625 as Waxing Crescent" do
      phase_name = calculator.send(:classify_phase, 0.0625)

      expect(phase_name).to eq("Waxing Crescent")
    end

    it "classifies fraction just below 0.0625 as New Moon" do
      phase_name = calculator.send(:classify_phase, 0.0624)

      expect(phase_name).to eq("New Moon")
    end

    it "classifies fraction at 0.4375 as Full Moon" do
      phase_name = calculator.send(:classify_phase, 0.4375)

      expect(phase_name).to eq("Full Moon")
    end

    it "classifies fraction at 0.5625 as Waning Gibbous" do
      phase_name = calculator.send(:classify_phase, 0.5625)

      expect(phase_name).to eq("Waning Gibbous")
    end

    it "classifies fraction at 0.8125 as Waning Crescent" do
      phase_name = calculator.send(:classify_phase, 0.8125)

      expect(phase_name).to eq("Waning Crescent")
    end
  end
end
