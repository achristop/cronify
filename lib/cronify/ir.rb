# frozen_string_literal: true

module Cronify
  # Intermediate Representation — the structured output of the parser,
  # before any cron string is produced.
  IR = Struct.new(
    :type, # Symbol: :interval, :daily, :weekday, :weekend, :ordinal_weekday, :bounded_interval
    :interval, # Integer — the N in "every N hours/minutes"
    :unit,     # Symbol: :hour or :minute
    :hour, # Integer 0–23
    :minute, # Integer 0–59
    :days_of_week, # Array<Integer> — 0=Sun, 1=Mon, …, 6=Sat
    :ordinal, # Symbol: :first, :second, :third, :fourth, :last
    :weekday, # Integer 0–6 — used with ordinal
    :hour_range # [start_hour, end_hour] — used by bounded interval
  )
end
