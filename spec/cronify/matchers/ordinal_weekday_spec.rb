# frozen_string_literal: true

RSpec.describe Cronify::Matchers::OrdinalWeekday do
  subject(:matcher) { described_class.new }

  describe "#match?" do
    it { expect(matcher.match?("first Monday of each month at noon")).to be true }
    it { expect(matcher.match?("last Friday of every month at 5pm")).to be true }
    it { expect(matcher.match?("every weekday at 9am")).to be false }
  end

  describe "#parse" do
    it "returns correct IR for first Monday" do
      ir = matcher.parse("first Monday of each month at noon")
      expect(ir.ordinal).to eq(:first)
      expect(ir.weekday).to eq(1)
      expect(ir.hour).to eq(12)
    end

    it "returns correct IR for last Friday" do
      ir = matcher.parse("last Friday of each month at 5pm")
      expect(ir.ordinal).to eq(:last)
      expect(ir.weekday).to eq(5)
      expect(ir.hour).to eq(17)
    end
  end
end
