#!/usr/bin/env ruby
# frozen_string_literal: true

# Add the lib directory to the load path
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'moon_phase_tracker'

puts '=== Moon Phase Tracker - 8 Phases Example ==='
puts 'Demonstrating all 8 lunar phases (4 major + 4 intermediate)'
puts ''

begin
  # Example 1: Get all 8 phases for August 2025
  puts '🌙 All phases for August 2025:'
  puts '=' * 40
  phases = MoonPhaseTracker.all_phases_for_month(2025, 8)

  if phases.any?
    phases.each do |phase|
      prefix = phase.interpolated ? '~ ' : '  '
      puts "#{prefix}#{phase}"
    end

    major_count = phases.count { |p| !p.interpolated }
    interpolated_count = phases.count(&:interpolated)

    puts ''
    puts "Total: #{phases.size} phases (#{major_count} major, #{interpolated_count} interpolated)"
    puts '~ indicates interpolated phases'
  else
    puts 'No phases found for this period.'
  end

  puts ''
  puts '-' * 50
  puts ''

  # Example 2: Compare 4 vs 8 phases
  puts '🔍 Comparison: 4 Major Phases vs 8 Complete Phases'
  puts '=' * 55

  major_phases = MoonPhaseTracker.phases_for_month(2025, 8)
  all_phases = MoonPhaseTracker.all_phases_for_month(2025, 8)

  puts "Major phases only (#{major_phases.size}):"
  major_phases.each { |phase| puts "  #{phase}" }

  puts ''
  puts "All phases including interpolated (#{all_phases.size}):"
  all_phases.each do |phase|
    prefix = phase.interpolated ? '~ ' : '  '
    puts "#{prefix}#{phase}"
  end

  puts ''
  puts '-' * 50
  puts ''

  # Example 3: Show phase symbols
  puts '🎭 Phase Symbols Reference'
  puts '=' * 30
  MoonPhaseTracker::Phase::PHASE_SYMBOLS.each do |type, symbol|
    name = type.to_s.split('_').map(&:capitalize).join(' ')
    puts "#{symbol} #{name}"
  end

  puts ''
  puts '-' * 50
  puts ''

  # Example 4: Get phases from a specific date with 8 phases
  puts '📅 8 Phases from a specific date (2025-08-01, 2 cycles)'
  puts '=' * 60
  date_phases = MoonPhaseTracker.all_phases_from_date('2025-08-01', 2)

  if date_phases.any?
    date_phases.each do |phase|
      prefix = phase.interpolated ? '~ ' : '  '
      puts "#{prefix}#{phase}"
    end

    major_count = date_phases.count { |p| !p.interpolated }
    interpolated_count = date_phases.count(&:interpolated)

    puts ''
    puts "Total: #{date_phases.size} phases over 2 lunar cycles"
    puts "(#{major_count} major, #{interpolated_count} interpolated)"
  end
rescue MoonPhaseTracker::Error => e
  puts "Error: #{e.message}"
rescue StandardError => e
  puts "Unexpected error: #{e.message}"
  puts 'This example requires an active internet connection to fetch moon phase data.'
end

puts ''
puts 'Note: This example uses real astronomical data from the US Naval Observatory.'
puts 'Interpolated phases (~) are calculated estimates between official phases.'
puts 'All dates are in ISO 8601 format (YYYY-MM-DD) and times are in UTC.'
