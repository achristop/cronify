# frozen_string_literal: true

module Cronify
  module Matchers
    class Daily < Base
      include TimeParser

      PATTERN = /\Aevery day at (?<time>\d{1,2}(?::\d{2})?(?:am|pm)|noon|midnight)\z/

      def parse(input)
        m = PATTERN.match(input.downcase.strip)
        hour, minute = parse_time(m[:time])
        IR.new(type: :daily, hour: hour, minute: minute)
      end
    end
  end
end
