# frozen_string_literal: true

module Cronify
  class CronEmitter
    ORDINAL_NUMBERS = { first: 1, second: 2, third: 3, fourth: 4 }.freeze

    def self.emit(ir)
      case ir.type
      when :interval         then emit_interval(ir)
      when :daily            then emit_daily(ir)
      when :weekday, :weekend then emit_weekday_weekend(ir)
      when :ordinal_weekday  then emit_ordinal_weekday(ir)
      when :bounded_interval then emit_bounded_interval(ir)
      else raise Cronify::Error, "Unknown IR type: #{ir.type}"
      end
    end

    private_class_method def self.emit_interval(ir)
      case ir.unit
      when :hour   then "0 */#{ir.interval} * * *"
      when :minute then "*/#{ir.interval} * * * *"
      end
    end

    private_class_method def self.emit_daily(ir)
      "#{ir.minute} #{ir.hour} * * *"
    end

    private_class_method def self.emit_weekday_weekend(ir)
      days = ir.type == :weekday ? "1-5" : "6,0"
      "#{ir.minute} #{ir.hour} * * #{days}"
    end

    private_class_method def self.emit_ordinal_weekday(ir)
      day_field = if ir.ordinal == :last
                    "#{ir.weekday}L"
                  else
                    "#{ir.weekday}##{ORDINAL_NUMBERS[ir.ordinal]}"
                  end
      "#{ir.minute} #{ir.hour} ? * #{day_field}"
    end

    private_class_method def self.emit_bounded_interval(ir)
      start_hour, end_hour = ir.hour_range
      hours = (start_hour..end_hour).step(ir.interval).to_a.join(",")
      "#{ir.minute} #{hours} * * *"
    end
  end
end
