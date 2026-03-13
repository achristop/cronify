# frozen_string_literal: true

RSpec.describe Cronify::Matchers::TimeBoundedInterval do
  subject(:matcher) { described_class.new }

  describe "#match?" do
    it { expect(matcher.match?("every 2 hours between 8am and 6pm")).to be true }
    it { expect(matcher.match?("every 2 hours")).to be false }
  end

  describe "#parse" do
    it "returns correct IR" do
      ir = matcher.parse("every 2 hours between 8am and 6pm")
      expect(ir.type).to eq(:bounded_interval)
      expect(ir.interval).to eq(2)
      expect(ir.hour_range).to eq([8, 18])
    end
  end
end
