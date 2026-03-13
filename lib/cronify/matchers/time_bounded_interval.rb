# frozen_string_literal: true

module Cronify
  module Matchers
    class TimeBoundedInterval < Base
      include TimeParser

      PATTERN = /\Aevery (?<interval>\d+) hours? between (?<from>\d{1,2}(?:am|pm)) and (?<to>\d{1,2}(?:am|pm))\z/

      def parse(input)
        m = PATTERN.match(input.downcase.strip)
        from_hour, = parse_time(m[:from])
        to_hour,   = parse_time(m[:to])
        IR.new(
          type: :bounded_interval,
          interval: m[:interval].to_i,
          hour_range: [from_hour, to_hour],
          minute: 0
        )
      end
    end
  end
end
