# frozen_string_literal: true

require_relative "cronify/version"
require_relative "cronify/time_parser"
require_relative "cronify/ir"
require_relative "cronify/schedule"
require_relative "cronify/matchers/base"
require_relative "cronify/matchers/simple_interval"
require_relative "cronify/matchers/daily"
require_relative "cronify/matchers/weekday_weekend"
require_relative "cronify/matchers/ordinal_weekday"
require_relative "cronify/matchers/time_bounded_interval"
require_relative "cronify/dispatcher"
require_relative "cronify/cron_emitter"

# Top-level namespace for the Cronify gem.
#
# Provides a single entry point {Cronify.parse} that converts a natural language
# schedule description into a {Cronify::Schedule} object containing the cron
# expression and next-occurrence timestamps.
module Cronify
  # Base error class for all Cronify exceptions.
  class Error < StandardError; end

  # Raised when the input string does not match any known schedule pattern.
  class ParseError < Error; end

  # Raised when the input string matches more than one pattern ambiguously.
  class AmbiguousInputError < Error; end

  # Parses a natural language schedule string into a {Schedule} object.
  #
  # @example Simple interval
  #   Cronify.parse("every 2 hours")
  #
  # @example Weekday schedule with timezone
  #   Cronify.parse("every weekday at 9am", timezone: "Europe/Athens")
  #
  # @example Ordinal weekday
  #   Cronify.parse("first Monday of each month at noon")
  #
  # @param input [String] a natural language schedule description
  # @param timezone [String] a TZInfo timezone identifier (default: "UTC")
  # @return [Schedule] the parsed schedule with cron expression and next occurrences
  # @raise [Cronify::ParseError] if the input is not a recognized pattern
  # @raise [Cronify::Error] if the timezone identifier is invalid
  def self.parse(input, timezone: "UTC")
    ir = Dispatcher.dispatch(input)
    cron = CronEmitter.emit(ir)
    Schedule.new(cron: cron, timezone: timezone, original_input: input)
  end
end
