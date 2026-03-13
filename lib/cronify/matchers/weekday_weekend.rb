# frozen_string_literal: true

module Cronify
  module Matchers
    class WeekdayWeekend < Base
      include TimeParser

      PATTERN = /\Aevery (?<scope>weekday|weekend) at (?<time>\d{1,2}(?::\d{2})?(?:am|pm)|noon|midnight)\z/

      DAYS = {
        "weekday" => [1, 2, 3, 4, 5],
        "weekend" => [6, 0]
      }.freeze

      def parse(input)
        m = PATTERN.match(input.downcase.strip)
        hour, minute = parse_time(m[:time])
        IR.new(
          type: m[:scope].to_sym,
          hour: hour,
          minute: minute,
          days_of_week: DAYS[m[:scope]]
        )
      end
    end
  end
end
