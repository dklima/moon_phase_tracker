#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/moon_phase_tracker'

puts '=== Moon Phase Tracker - Usage Examples =='
puts

tracker = MoonPhaseTracker::Tracker.new

begin
  puts '1. Moon phases for August 2025:'
  puts '-' * 40
  august_phases = MoonPhaseTracker.phases_for_month(2025, 8)
  puts tracker.format_phases(august_phases, "#{MoonPhaseTracker::Tracker.month_name(8)} 2025 Phases")
  puts

  puts '2. All moon phases in 2025 (first 8):'
  puts '-' * 50
  year_phases = MoonPhaseTracker.phases_for_year(2025)
  puts tracker.format_phases(year_phases.first(8), 'First 8 phases of 2025')
  puts

  puts '3. Next 6 phases starting from 2025-08-01:'
  puts '-' * 45
  future_phases = MoonPhaseTracker.phases_from_date('2025-08-01', 6)
  puts tracker.format_phases(future_phases, 'Upcoming phases')
  puts

  puts '4. Current month phases:'
  puts '-' * 25
  current_phases = tracker.current_month_phases
  if current_phases.any?
    puts tracker.format_phases(current_phases, 'Current month phases')
  else
    puts 'No phases found for the current month.'
  end
  puts

  puts '5. Next moon phase:'
  puts '-' * 25
  next_phase = tracker.next_phase
  if next_phase
    puts next_phase
    puts "Details: #{next_phase.to_h}"
  else
    puts 'Could not retrieve the next phase.'
  end
  puts

  puts '6. Different phase representations:'
  puts '-' * 42
  if august_phases.any?
    phase = august_phases.first
    puts "String: #{phase}"
    puts "Hash: #{phase.to_h}"
    puts "Symbol: #{phase.symbol}"
    puts "Formatted date: #{phase.formatted_date}"
    puts "Formatted time: #{phase.formatted_time}"
  end
rescue MoonPhaseTracker::NetworkError => e
  puts "Network error: #{e.message}"
  puts 'Please check your internet connection.'
rescue MoonPhaseTracker::APIError => e
  puts "API error: #{e.message}"
  puts 'The service may be temporarily unavailable.'
rescue MoonPhaseTracker::InvalidDateError => e
  puts "Date error: #{e.message}"
rescue StandardError => e
  puts "Unexpected error: #{e.message}"
end

puts
puts '=== End of Examples ==='
