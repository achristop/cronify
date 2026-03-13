# frozen_string_literal: true

module Cronify
  class Dispatcher
    MATCHERS = [
      Matchers::TimeBoundedInterval,
      Matchers::OrdinalWeekday,
      Matchers::WeekdayWeekend,
      Matchers::Daily,
      Matchers::SimpleInterval
    ].freeze

    def self.dispatch(input)
      matcher = MATCHERS.map(&:new).find { |m| m.match?(input) }
      raise Cronify::ParseError, "Unrecognized schedule: '#{input}'" unless matcher

      matcher.parse(input)
    end
  end
end
