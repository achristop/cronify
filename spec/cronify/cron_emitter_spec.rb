# frozen_string_literal: true

RSpec.describe Cronify::CronEmitter do
  describe ".emit" do
    context "with an interval type" do
      it "emits hourly interval" do
        ir = Cronify::IR.new(type: :interval, unit: :hour, interval: 2, minute: 0)
        expect(described_class.emit(ir)).to eq("0 */2 * * *")
      end

      it "emits minute interval" do
        ir = Cronify::IR.new(type: :interval, unit: :minute, interval: 30, minute: 0)
        expect(described_class.emit(ir)).to eq("*/30 * * * *")
      end
    end

    context "with a daily type" do
      it "emits correct cron" do
        ir = Cronify::IR.new(type: :daily, hour: 9, minute: 0)
        expect(described_class.emit(ir)).to eq("0 9 * * *")
      end

      it "preserves minutes" do
        ir = Cronify::IR.new(type: :daily, hour: 9, minute: 30)
        expect(described_class.emit(ir)).to eq("30 9 * * *")
      end
    end

    context "with weekday or weekend type" do
      it "emits weekday cron" do
        ir = Cronify::IR.new(type: :weekday, hour: 9, minute: 0, days_of_week: [1, 2, 3, 4, 5])
        expect(described_class.emit(ir)).to eq("0 9 * * 1-5")
      end

      it "emits weekend cron" do
        ir = Cronify::IR.new(type: :weekend, hour: 10, minute: 0, days_of_week: [6, 0])
        expect(described_class.emit(ir)).to eq("0 10 * * 6,0")
      end
    end

    context "with an ordinal weekday (Quartz/Sidekiq syntax)" do
      it "emits first Monday" do
        ir = Cronify::IR.new(type: :ordinal_weekday, ordinal: :first, weekday: 1, hour: 12, minute: 0)
        expect(described_class.emit(ir)).to eq("0 12 ? * 1#1")
      end

      it "emits third Wednesday" do
        ir = Cronify::IR.new(type: :ordinal_weekday, ordinal: :third, weekday: 3, hour: 8, minute: 0)
        expect(described_class.emit(ir)).to eq("0 8 ? * 3#3")
      end

      it "emits last Friday" do
        ir = Cronify::IR.new(type: :ordinal_weekday, ordinal: :last, weekday: 5, hour: 17, minute: 0)
        expect(described_class.emit(ir)).to eq("0 17 ? * 5L")
      end
    end

    context "with a bounded interval" do
      it "enumerates hours correctly" do
        ir = Cronify::IR.new(type: :bounded_interval, interval: 2, hour_range: [8, 18], minute: 0)
        expect(described_class.emit(ir)).to eq("0 8,10,12,14,16,18 * * *")
      end

      it "handles a 3-hour interval" do
        ir = Cronify::IR.new(type: :bounded_interval, interval: 3, hour_range: [6, 18], minute: 0)
        expect(described_class.emit(ir)).to eq("0 6,9,12,15,18 * * *")
      end
    end

    context "with an unknown type" do
      it "raises Cronify::Error" do
        ir = Cronify::IR.new(type: :unknown)
        expect { described_class.emit(ir) }.to raise_error(Cronify::Error)
      end
    end
  end
end
