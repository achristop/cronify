# frozen_string_literal: true

require "timecop"

RSpec.describe Cronify::Schedule do
  def build(cron:, timezone: "UTC")
    described_class.new(cron: cron, timezone: timezone, original_input: "test")
  end

  describe "#next_occurrences" do
    context "with a simple daily schedule" do
      it "returns the correct next fire time when before the scheduled hour" do
        Timecop.freeze(Time.utc(2026, 3, 16, 6, 0, 0)) do
          schedule = build(cron: "0 9 * * *")
          expect(schedule.next_occurrence).to eq(Time.utc(2026, 3, 16, 9, 0, 0))
        end
      end

      it "returns the next day when already past the scheduled hour" do
        Timecop.freeze(Time.utc(2026, 3, 16, 10, 0, 0)) do
          schedule = build(cron: "0 9 * * *")
          expect(schedule.next_occurrence).to eq(Time.utc(2026, 3, 17, 9, 0, 0))
        end
      end
    end

    context "with a weekday schedule" do
      it "skips weekend days" do
        # Friday 2026-03-20 at 10am — next weekday at 9am is Monday 2026-03-23
        Timecop.freeze(Time.utc(2026, 3, 20, 10, 0, 0)) do
          schedule = build(cron: "0 9 * * 1-5")
          expect(schedule.next_occurrence).to eq(Time.utc(2026, 3, 23, 9, 0, 0))
        end
      end
    end

    context "when crossing a month boundary" do
      it "rolls over to the next month correctly" do
        # March 31 at 10am — next daily at 9am is April 1
        Timecop.freeze(Time.utc(2026, 3, 31, 10, 0, 0)) do
          schedule = build(cron: "0 9 * * *")
          expect(schedule.next_occurrence).to eq(Time.utc(2026, 4, 1, 9, 0, 0))
        end
      end
    end

    context "when in a leap year" do
      it "handles Feb 28 rolling to Feb 29 in a leap year" do
        Timecop.freeze(Time.utc(2028, 2, 28, 10, 0, 0)) do
          schedule = build(cron: "0 9 * * *")
          expect(schedule.next_occurrence).to eq(Time.utc(2028, 2, 29, 9, 0, 0))
        end
      end
    end

    context "with multiple occurrences" do
      it "returns exactly n results" do
        Timecop.freeze(Time.utc(2026, 3, 16, 6, 0, 0)) do
          schedule = build(cron: "0 9 * * *")
          expect(schedule.next_occurrences(n: 7).size).to eq(7)
        end
      end

      it "returns results in ascending order" do
        Timecop.freeze(Time.utc(2026, 3, 16, 6, 0, 0)) do
          schedule = build(cron: "0 9 * * *")
          times = schedule.next_occurrences(n: 5)
          expect(times).to eq(times.sort)
        end
      end

      it "each occurrence is 1 day apart for a daily schedule" do
        Timecop.freeze(Time.utc(2026, 3, 16, 6, 0, 0)) do
          schedule = build(cron: "0 9 * * *")
          times = schedule.next_occurrences(n: 3)
          gaps = times.each_cons(2).map { |a, b| b - a }
          expect(gaps).to all(eq(86_400)) # 24 hours in seconds
        end
      end
    end

    context "with timezone" do
      it "raises Cronify::Error for an invalid timezone" do
        expect { build(cron: "0 9 * * *", timezone: "Not/Real") }
          .to raise_error(Cronify::Error, %r{Not/Real})
      end

      it "accepts a valid non-UTC timezone" do
        expect { build(cron: "0 9 * * *", timezone: "Europe/Athens") }
          .not_to raise_error
      end
    end
  end
end
