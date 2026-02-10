# frozen_string_literal: true

module MoonPhaseTracker
  class LunarCalculator
    SYNODIC_MONTH = 29.530588853
    KNOWN_NEW_MOON_JD = 2451550.26 # Jan 6, 2000 18:14 UTC

    PHASE_BOUNDARIES = [
      [ 0.0,    "New Moon" ],
      [ 0.0625, "Waxing Crescent" ],
      [ 0.1875, "First Quarter" ],
      [ 0.3125, "Waxing Gibbous" ],
      [ 0.4375, "Full Moon" ],
      [ 0.5625, "Waning Gibbous" ],
      [ 0.6875, "Last Quarter" ],
      [ 0.8125, "Waning Crescent" ]
    ].freeze

    def phase_at(date)
      time = coerce_to_time(date)
      fraction = cycle_position(time)
      age = lunar_age(time)
      illum = illumination_from_fraction(fraction)
      name = classify_phase(fraction)

      Phase.from_calculation(
        name: name,
        date: time.utc.to_date,
        time: time.utc.strftime("%H:%M"),
        illumination: illum,
        lunar_age: age
      )
    end

    def illumination(date)
      fraction = cycle_position(coerce_to_time(date))
      illumination_from_fraction(fraction)
    end

    def lunar_age(date)
      time = coerce_to_time(date)
      jd = to_julian_date(time)
      days_since = jd - KNOWN_NEW_MOON_JD
      days_since % SYNODIC_MONTH
    end

    def cycle_position(date)
      time = coerce_to_time(date)
      jd = to_julian_date(time)
      days_since = jd - KNOWN_NEW_MOON_JD
      (days_since % SYNODIC_MONTH) / SYNODIC_MONTH
    end

    private

    def coerce_to_time(input)
      case input
      when Time then input.utc
      when DateTime then input.to_time.utc
      when Date then Time.utc(input.year, input.month, input.day, 12)
      when String then coerce_to_time(Date.parse(input))
      else raise ArgumentError, "Expected Date, Time, DateTime, or String. Got #{input.class}"
      end
    rescue Date::Error => e
      raise ArgumentError, "Cannot parse date string: #{input.inspect} (#{e.message})"
    end

    def to_julian_date(time)
      utc = time.utc
      y = utc.year
      m = utc.month
      d = utc.day + (utc.hour + utc.min / 60.0 + utc.sec / 3600.0) / 24.0

      if m <= 2
        y -= 1
        m += 12
      end

      a = (y / 100).floor
      b = 2 - a + (a / 4).floor

      (365.25 * (y + 4716)).floor + (30.6001 * (m + 1)).floor + d + b - 1524.5
    end

    def illumination_from_fraction(fraction)
      ((1 - Math.cos(2 * Math::PI * fraction)) / 2.0 * 100).round(2)
    end

    def classify_phase(fraction)
      PHASE_BOUNDARIES.reverse_each do |threshold, name|
        return name if fraction >= threshold
      end
      PHASE_BOUNDARIES.first.last
    end
  end
end
