# frozen_string_literal: true

RSpec.describe Cronify::Dispatcher do
  describe ".dispatch" do
    it "returns an IR for a recognized input" do
      expect(described_class.dispatch("every 2 hours")).to be_a(Cronify::IR)
    end

    it "raises ParseError for unrecognized input" do
      expect { described_class.dispatch("whenever I feel like it") }
        .to raise_error(Cronify::ParseError, /whenever I feel like it/)
    end

    it "dispatches bounded interval over simple interval" do
      ir = described_class.dispatch("every 2 hours between 8am and 6pm")
      expect(ir.type).to eq(:bounded_interval)
    end
  end
end
