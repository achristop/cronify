# frozen_string_literal: true

RSpec.describe Cronify::Matchers::Daily do
  subject(:matcher) { described_class.new }

  describe "#match?" do
    it { expect(matcher.match?("every day at 9am")).to be true }
    it { expect(matcher.match?("every day at noon")).to be true }
    it { expect(matcher.match?("every day at midnight")).to be true }
    it { expect(matcher.match?("every weekday at 9am")).to be false }
    it { expect(matcher.match?("every 2 hours")).to be false }
  end

  describe "#parse" do
    it "returns correct IR for 9am" do
      ir = matcher.parse("every day at 9am")
      expect(ir.type).to eq(:daily)
      expect(ir.hour).to eq(9)
      expect(ir.minute).to eq(0)
    end

    it "parses noon as hour 12" do
      ir = matcher.parse("every day at noon")
      expect(ir.hour).to eq(12)
    end

    it "parses midnight as hour 0" do
      ir = matcher.parse("every day at midnight")
      expect(ir.hour).to eq(0)
    end

    it "parses pm hours correctly" do
      ir = matcher.parse("every day at 5pm")
      expect(ir.hour).to eq(17)
    end
  end
end
