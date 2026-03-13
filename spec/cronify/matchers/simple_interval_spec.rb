# frozen_string_literal: true

RSpec.describe Cronify::Matchers::SimpleInterval do
  subject(:matcher) { described_class.new }

  describe "#match?" do
    it { expect(matcher.match?("every 2 hours")).to be true }
    it { expect(matcher.match?("every 30 minutes")).to be true }
    it { expect(matcher.match?("every weekday at 9am")).to be false }
  end

  describe "#parse" do
    it "returns correct IR for hours" do
      ir = matcher.parse("every 2 hours")
      expect(ir.type).to eq(:interval)
      expect(ir.interval).to eq(2)
      expect(ir.unit).to eq(:hour)
    end

    it "returns correct IR for minutes" do
      ir = matcher.parse("every 30 minutes")
      expect(ir.unit).to eq(:minute)
      expect(ir.interval).to eq(30)
    end
  end
end
