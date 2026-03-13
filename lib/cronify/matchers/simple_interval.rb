# frozen_string_literal: true

module Cronify
  module Matchers
    class SimpleInterval < Base
      PATTERN = /\Aevery (?<interval>\d+) (?<unit>hours?|minutes?)\z/

      def parse(input)
        m = PATTERN.match(input.downcase.strip)
        unit = m[:unit].start_with?("hour") ? :hour : :minute
        IR.new(type: :interval, interval: m[:interval].to_i, unit: unit, minute: 0)
      end
    end
  end
end
