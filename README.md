# Bot that triggers Trainline

- Technologies used: Ruby, linter(Standard), RSpec.
- Bot responds to `ComThetrainline.find(from, to, departure_at)` in  `com_thetrainline.rb` file.
- By default, it runs with the following arguments: `ComThetrainline.find("Berlin Hbf", "Warszawa-Centralna", "#<DateTime: 2025-03-12T14:00:00+00:00 ((2456774j,22140s,0n),+0s,2299161j)>")`.
- Added error handling. Configured CI for running specs and linter.

## Setup instructions

1. Make sure you have Ruby installed.
2. Install dependencies with the cmd `bundle install`
3. Run `ruby com_thetrainline.rb` to start the bot.

## Space for improvements

1. Leverage I18n for error messages.
2. Add caching(Redis/Memchached) for fetching location codes as they don't change frequently. This will reduce the load 
on Trainline, improve response times, and speed up the overall performance of the application.
3. Improve test coverage by adding more test cases(unit test for JourneysParserService and integration spec for ComThetrainline).
4. Log errors and integrate monitoring systems(Sentry).
