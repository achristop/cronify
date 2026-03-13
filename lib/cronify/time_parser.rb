# frozen_string_literal: true

module Cronify
  module TimeParser
    TIME_PATTERN = /\A(?<hour>\d{1,2})(?::(?<min>\d{2}))?(?<period>am|pm)\z/

    def parse_time(str)
      return [0, 0] if str == "midnight"
      return [12, 0] if str == "noon"

      m = TIME_PATTERN.match(str)
      raise Cronify::ParseError, "Unrecognized time format: #{str}" unless m

      hour = m[:hour].to_i
      minute = m[:min].to_i
      hour += 12 if m[:period] == "pm" && hour != 12
      hour = 0 if m[:period] == "am" && hour == 12

      [hour, minute]
    end
  end
end
