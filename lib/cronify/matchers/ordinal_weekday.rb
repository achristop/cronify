# frozen_string_literal: true

module Cronify
  module Matchers
    class OrdinalWeekday < Base
      include TimeParser

      PATTERN = /
        \A
        (?<ordinal>first|second|third|fourth|last)\s
        (?<weekday>monday|tuesday|wednesday|thursday|friday|saturday|sunday)\s
        of\s(?:each|every)\smonth\sat\s
        (?<time>\d{1,2}(?::\d{2})?(?:am|pm)|noon|midnight)
        \z
      /x

      ORDINALS = {
        "first" => :first, "second" => :second,
        "third" => :third, "fourth" => :fourth, "last" => :last
      }.freeze

      WEEKDAYS = {
        "sunday" => 0, "monday" => 1, "tuesday" => 2,
        "wednesday" => 3, "thursday" => 4, "friday" => 5, "saturday" => 6
      }.freeze

      def parse(input)
        m = PATTERN.match(input.downcase.strip)
        hour, minute = parse_time(m[:time])
        IR.new(
          type: :ordinal_weekday,
          ordinal: ORDINALS[m[:ordinal]],
          weekday: WEEKDAYS[m[:weekday]],
          hour: hour,
          minute: minute
        )
      end
    end
  end
end
