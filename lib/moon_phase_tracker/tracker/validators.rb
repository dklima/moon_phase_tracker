# frozen_string_literal: true

module MoonPhaseTracker
  module Validators
    # Validation module for input parameters
    # Centralizes all validation logic following DRY principle

    private

    # Validate year parameter
    # @param year [Integer] Year to validate
    # @raise [InvalidDateError] If year is invalid
    def validate_year!(year)
      current_year = Date.today.year
      valid_range = (1700..current_year + 10)

      return if year.is_a?(Integer) && valid_range.cover?(year)

      raise InvalidDateError, "Year must be between #{valid_range.min} and #{valid_range.max}"
    end

    # Validate month and year parameters
    # @param year [Integer] Year to validate
    # @param month [Integer] Month to validate (1-12)
    # @raise [InvalidDateError] If month or year is invalid
    def validate_month!(year, month)
      validate_year!(year)

      return if month.is_a?(Integer) && (1..12).cover?(month)

      raise InvalidDateError, "Month must be between 1 and 12"
    end

    # Validate number of phases parameter
    # @param num_phases [Integer] Number of phases to validate
    # @raise [InvalidDateError] If number of phases is invalid
    def validate_num_phases!(num_phases)
      valid_range = (1..99)

      return if num_phases.is_a?(Integer) && valid_range.cover?(num_phases)

      raise InvalidDateError, "Number of phases must be between #{valid_range.min} and #{valid_range.max}"
    end
  end
end