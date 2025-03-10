# Bot that triggers Trainline

- Technologies used: Ruby, linter(Standard), RSpec, Redis.
- Bot responds to `ComThetrainline.find(from, to, departure_at)` in  `com_thetrainline.rb` file.
- Added input validations, error handling. Configured CI for running specs and linter.
- Implemented caching using Redis for fetching location codes as they don't change frequently. This will reduce the load
on Trainline, improve response times, and speed up the overall performance of the application.

## Setup instructions

1. Make sure you have Ruby installed.
2. Install dependencies with the cmd `bundle install`
3. Run the bot with the cmd `ruby com_thetrainline.rb`

## Space for improvements

1. Leverage I18n for error messages.
2. Improve test coverage by adding more test cases(unit tests for JourneysParserService and more integration specs for 
ComThetrainline).
3. Log errors and integrate monitoring systems(Sentry).
