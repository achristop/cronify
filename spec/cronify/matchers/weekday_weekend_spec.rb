# frozen_string_literal: true

RSpec.describe Cronify::Matchers::WeekdayWeekend do
  subject(:matcher) { described_class.new }

  describe "#match?" do
    it { expect(matcher.match?("every weekday at 9am")).to be true }
    it { expect(matcher.match?("every weekend at 10am")).to be true }
    it { expect(matcher.match?("every 2 hours")).to be false }
  end

  describe "#parse" do
    it "returns weekday days for weekday scope" do
      ir = matcher.parse("every weekday at 9am")
      expect(ir.days_of_week).to eq([1, 2, 3, 4, 5])
      expect(ir.hour).to eq(9)
    end

    it "returns weekend days for weekend scope" do
      ir = matcher.parse("every weekend at 10am")
      expect(ir.days_of_week).to eq([6, 0])
    end

    it "parses noon correctly" do
      ir = matcher.parse("every weekday at noon")
      expect(ir.hour).to eq(12)
    end
  end
end
