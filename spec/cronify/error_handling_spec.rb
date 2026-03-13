# frozen_string_literal: true

RSpec.describe Cronify do
  describe "unrecognized input" do
    it "raises ParseError" do
      expect { described_class.parse("whenever I feel like it") }
        .to raise_error(Cronify::ParseError)
    end

    it "includes the original input in the message" do
      expect { described_class.parse("whenever I feel like it") }
        .to raise_error(Cronify::ParseError, /whenever I feel like it/)
    end

    it "is a subclass of Cronify::Error" do
      expect(Cronify::ParseError.ancestors).to include(Cronify::Error)
    end
  end

  describe "invalid timezone" do
    it "raises Cronify::Error" do
      expect { described_class.parse("every day at 9am", timezone: "Fake/Zone") }
        .to raise_error(Cronify::Error)
    end

    it "includes the invalid timezone in the message" do
      expect { described_class.parse("every day at 9am", timezone: "Fake/Zone") }
        .to raise_error(Cronify::Error, %r{Fake/Zone})
    end

    it "includes a usage hint in the message" do
      expect { described_class.parse("every day at 9am", timezone: "Fake/Zone") }
        .to raise_error(Cronify::Error, /TZInfo/)
    end
  end

  describe "Cronify::Error hierarchy" do
    it "Cronify::Error is a StandardError" do
      expect(Cronify::Error.ancestors).to include(StandardError)
    end

    it "Cronify::ParseError is a Cronify::Error" do
      expect(Cronify::ParseError.ancestors).to include(Cronify::Error)
    end

    it "Cronify::AmbiguousInputError is a Cronify::Error" do
      expect(Cronify::AmbiguousInputError.ancestors).to include(Cronify::Error)
    end
  end
end
