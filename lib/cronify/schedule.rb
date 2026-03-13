# frozen_string_literal: true

require "fugit"
require "tzinfo"

module Cronify
  # Represents a parsed schedule.
  #
  # Holds the cron expression produced by {Cronify.parse} and provides methods
  # to calculate future fire times. Instances are immutable — all attributes
  # are read-only after initialization.
  class Schedule
    # @return [String] the cron expression in Quartz/Sidekiq syntax
    attr_reader :cron

    # @return [String] the TZInfo timezone identifier used for this schedule
    attr_reader :timezone

    # @return [String] the original natural language input string
    attr_reader :original_input

    # @param cron [String] a valid cron expression in Quartz/Sidekiq syntax
    # @param timezone [String] a TZInfo timezone identifier (e.g. "UTC", "Europe/Athens")
    # @param original_input [String] the original input string, stored for reference
    # @raise [Cronify::Error] if the timezone identifier is not recognized
    def initialize(cron:, timezone:, original_input:)
      @cron           = cron
      @timezone       = validate_timezone!(timezone)
      @original_input = original_input
    end

    # Returns the next time this schedule fires.
    #
    # @return [Time] the next occurrence
    def next_occurrence
      next_occurrences(n: 1).first
    end

    # Returns the next N times this schedule fires, in ascending order.
    #
    # @param n [Integer] number of occurrences to return (default:5)
    # @return [Array<Time>] next N fire times
    def next_occurrences(n: 5)
      tz       = TZInfo::Timezone.get(timezone)
      fugit_cr = Fugit::Cron.parse(cron)
      raise Cronify::Error, "Invalid cron expression: #{cron}" unless fugit_cr

      now = tz.utc_to_local(Time.now.utc)
      Array.new(n).each_with_object([]) do |_, times|
        reference = times.last || now
        times << fugit_cr.next_time(reference).to_t
      end
    end

    private

    def validate_timezone!(tz)
      TZInfo::Timezone.get(tz)
      tz
    rescue TZInfo::InvalidTimezoneIdentifier
      raise Error,
            "Unknown timezone: '#{tz}'. Use a valid TZInfo identifier (e.g. 'Europe/Athens', 'America/New_York')."
    end
  end
end
