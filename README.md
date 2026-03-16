# Cronify

Parse human-friendly schedule descriptions into cron expressions and next-occurrence timestamps.

```ruby
Cronify.parse("every weekday at 9am")
# => #<Cronify::Schedule cron="0 9 * * 1-5" ...>

Cronify.parse("first Monday of each month at noon")
# => #<Cronify::Schedule cron="0 12 ? * 1#1" ...>

Cronify.parse("every 2 hours between 8am and 6pm")
# => #<Cronify::Schedule cron="0 8,10,12,14,16,18 * * *" ...>
```

Cronify fills the gap between raw cron syntax and heavy scheduling libraries. It outputs cron strings compatible with Sidekiq, Whenever, and similar tools, plus the next N fire times as Ruby `Time` objects.

## Installation

```bash
bundle add cronify
```

Or add to your Gemfile manually:

```ruby
gem "cronify"
```

## Usage

### Parsing a schedule

```ruby
schedule = Cronify.parse("every weekday at 9am")

schedule.cron                     # => "0 9 * * 1-5"
schedule.next_occurrence          # => 2026-03-16 09:00:00 UTC
schedule.next_occurrences(n: 3)   # => [2026-03-16 09:00:00 UTC, 2026-03-17 09:00:00 UTC, 2026-03-18 09:00:00 UTC]
schedule.original_input           # => "every weekday at 9am"
schedule.timezone                 # => "UTC"
```

### Timezones

Pass any valid [TZInfo identifier](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) via the `timezone:` keyword:

```ruby
schedule = Cronify.parse("every weekday at 9am", timezone: "Europe/Athens")
schedule.next_occurrence # => time expressed in Europe/Athens
```

An invalid timezone raises `Cronify::Error` immediately with a descriptive message.

## Supported patterns

| Input                                                                | Cron output                    |
|----------------------------------------------------------------------|--------------------------------|
| `"every N hours"`                                                    | `0 */N * * *`                  |
| `"every N minutes"`                                                  | `*/N * * * *`                  |
| `"every day at <time>"`                                              | `0 H * * *`                    |
| `"every weekday at <time>"`                                          | `0 H * * 1-5`                  |
| `"every weekend at <time>"`                                          | `0 H * * 6,0`                  |
| `"first/second/third/fourth/last <weekday> of each month at <time>"` | `0 H ? * W#N` / `0 H ? * WL`   |
| `"every N hours between <time> and <time>"`                          | `0 H1,H2,... * * *`            |

**Accepted time formats:** `9am`, `5pm`, `9:30am`, `noon`, `midnight`

### Cron dialect

Cronify targets **Quartz/Sidekiq cron syntax**. This means:

- Ordinal weekday patterns use `#N` notation: `1#1` = first Monday, `5#3` = third Friday
- Last weekday of month uses `L` suffix: `5L` = last Friday
- The `?` wildcard is used in the day-of-month field when day-of-week is specified

This syntax is supported by [Sidekiq Pro](https://sidekiq.org), [sidekiq-cron](https://github.com/sidekiq-cron/sidekiq-cron), and [Whenever](https://github.com/javan/whenever). It is **not** compatible with standard POSIX cron.

## Error handling

```ruby
# Unrecognized input
Cronify.parse("whenever I feel like it")
# => raises Cronify::ParseError: Unrecognized schedule: 'whenever I feel like it'

# Invalid timezone
Cronify.parse("every day at 9am", timezone: "Not/Real")
# => raises Cronify::Error: Unknown timezone: 'Not/Real'. Use a valid TZInfo identifier...
```

### Exception hierarchy

```
StandardError
└── Cronify::Error
    ├── Cronify::ParseError           # input string not recognized
    └── Cronify::AmbiguousInputError  # input matches multiple patterns
```

## Development

```bash
bin/setup            # install dependencies
bundle exec rspec    # run tests
bundle exec rubocop  # lint
bin/console          # interactive prompt
```

## Releasing a new version

Releases are made from the `develop` branch using the `bin/bump` script:

```bash
bin/bump patch   # 0.4.1 → 0.4.2
bin/bump minor   # 0.4.1 → 0.5.0
bin/bump major   # 0.4.1 → 1.0.0
```

The script will:

1. Check that you are on the `develop` branch
2. Create a new `bump_version_x_x_x` branch
3. Update `lib/cronify/version.rb` and `Gemfile.lock`
4. Commit both files and create an annotated git tag

Once done, push the branch and open a PR against `develop`:

```bash
git push --set-upstream origin bump_version_x_x_x
git push --tags
```

After the PR is merged into `develop`, open a second PR from `develop` → `main`. Merging into `main` and pushing the tag triggers the release workflow, which publishes the gem to RubyGems.org and GitHub Packages automatically.

## Type signatures

Cronify ships with [RBS](https://github.com/ruby/rbs) type signatures in the `sig/` directory. To use them with your project's type checker:

```sh
bundle exec rbs collection install
```

Signatures cover the full public API (`Cronify.parse`, `Schedule`, and all error classes) and are validated in CI.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/achristopoulos/cronify.

## License

MIT — see [LICENSE.txt](LICENSE.txt).