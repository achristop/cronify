# frozen_string_literal: true

module Cronify
  module Matchers
    class Base
      def match?(input)
        self.class::PATTERN.match?(input.downcase.strip)
      end

      def parse(input)
        raise NotImplementedError, "#{self.class} must implement #parse"
      end
    end
  end
end
