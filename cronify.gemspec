# frozen_string_literal: true

require_relative "lib/cronify/version"

Gem::Specification.new do |spec|
  spec.name = "cronify"
  spec.version = Cronify::VERSION
  spec.authors = ["Andreas Christopoulos"]
  spec.email = ["andreas@christopoulos.me"]

  spec.summary = "Parse natural language schedules into cron expressions and next occurrences."
  spec.description = "Cronify parses human-friendly schedule descriptions (e.g. 'every weekday at 9am', 'first Monday of each month') into standard cron strings and next-occurrence timestamps. Designed for SaaS apps where users configure their own recurring schedules, with output compatible with Sidekiq, Whenever, and similar tools."
  spec.homepage = "https://github.com/achristop/cronify"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["allowed_push_host"] = nil
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/achristop/cronify/tree/main"
  spec.metadata["changelog_uri"] = "https://github.com/achristop/cronify/blob/main/CHANGELOG.md"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "fugit", "~> 1.11"
  spec.add_dependency "tzinfo", "~> 2.0"
end
