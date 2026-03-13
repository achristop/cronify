# frozen_string_literal: true

require "spec_helper"
require "timecop"

RSpec.describe Cronify do
  # Pin time to a known Monday so next-occurrence assertions are deterministic
  around { |example| Timecop.freeze(Time.utc(2026, 3, 16, 6, 0, 0)) { example.run } }

  describe ".parse" do
    context "with a valid input" do
      it "returns a Cronify::Schedule" do
        result = described_class.parse("every weekday at 9am")
        expect(result).to be_a(Cronify::Schedule)
      end

      it "exposes the original input" do
        result = described_class.parse("every weekday at 9am")
        expect(result.original_input).to eq("every weekday at 9am")
      end

      it "exposes the timezone" do
        result = described_class.parse("every weekday at 9am", timezone: "Europe/Athens")
        expect(result.timezone).to eq("Europe/Athens")
      end
    end

    context "with cron output" do
      it "parses 'every weekday at 9am'" do
        expect(described_class.parse("every weekday at 9am").cron).to eq("0 9 * * 1-5")
      end

      it "parses 'every weekend at 10am'" do
        expect(described_class.parse("every weekend at 10am").cron).to eq("0 10 * * 6,0")
      end

      it "parses 'every 2 hours'" do
        expect(described_class.parse("every 2 hours").cron).to eq("0 */2 * * *")
      end

      it "parses 'every 30 minutes'" do
        expect(described_class.parse("every 30 minutes").cron).to eq("*/30 * * * *")
      end

      it "parses 'every day at midnight'" do
        expect(described_class.parse("every day at midnight").cron).to eq("0 0 * * *")
      end

      it "parses 'every day at noon'" do
        expect(described_class.parse("every day at noon").cron).to eq("0 12 * * *")
      end

      it "parses 'first Monday of each month at noon' (Quartz/Sidekiq syntax)" do
        expect(described_class.parse("first Monday of each month at noon").cron).to eq("0 12 ? * 1#1")
      end

      it "parses 'last Friday of each month at 5pm'" do
        expect(described_class.parse("last Friday of each month at 5pm").cron).to eq("0 17 ? * 5L")
      end

      it "parses 'every 2 hours between 8am and 6pm'" do
        expect(described_class.parse("every 2 hours between 8am and 6pm").cron).to eq("0 8,10,12,14,16,18 * * *")
      end
    end

    context "with next_occurrence" do
      it "returns a Time object" do
        result = described_class.parse("every weekday at 9am")
        expect(result.next_occurrence).to be_a(Time)
      end

      it "returns the correct next fire time for 'every weekday at 9am'" do
        result = described_class.parse("every weekday at 9am")
        expect(result.next_occurrence).to eq(Time.utc(2026, 3, 16, 9, 0, 0))
      end
    end

    context "with next_occurrences" do
      it "returns an array of the requested size" do
        result = described_class.parse("every weekday at 9am")
        expect(result.next_occurrences(n: 3).size).to eq(3)
      end

      it "returns Time objects" do
        result = described_class.parse("every weekday at 9am")
        expect(result.next_occurrences(n: 3)).to all(be_a(Time))
      end

      it "returns occurrences in ascending order" do
        result = described_class.parse("every weekday at 9am")
        times = result.next_occurrences(n: 3)
        expect(times).to eq(times.sort)
      end
    end

    context "when input is unrecognized" do
      it "raises Cronify::ParseError for unrecognized input" do
        expect { described_class.parse("whenever I feel like it") }
          .to raise_error(Cronify::ParseError)
      end

      it "includes the unrecognized input in the error message" do
        expect { described_class.parse("whenever I feel like it") }
          .to raise_error(Cronify::ParseError, /whenever I feel like it/)
      end
    end
  end
end
