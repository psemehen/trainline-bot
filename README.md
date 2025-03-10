# Bot that triggers Trainline

- Technologies used: Ruby, linter(Standard), RSpec, Redis.
- Bot responds to `ComThetrainline.find(from, to, departure_at)` in  `com_thetrainline.rb` file.
- Added error handling. Configured CI for running specs and linter.
- Add caching using Redis for fetching location codes as they don't change frequently. This will reduce the load
on Trainline, improve response times, and speed up the overall performance of the application.

## Setup instructions

1. Make sure you have Ruby installed.
2. Install dependencies with the cmd `bundle install`
3. It's required to specify 3 environment variables while running the program: FROM, TO, DEPARTURE_AT. If not specified
it will raise an error. Example for running the bot: `FROM="Berlin Hbf" TO="Warszawa-Centralna" 
DEPARTURE_AT="#<DateTime:2025-03-12T14:00:00+00:00((2456774j,22140s,0n),+0s,2299161j)>" ruby com_thetrainline.rb`

## Space for improvements

1. Leverage I18n for error messages.
2. Improve test coverage by adding more test cases(unit test for JourneysParserService and integration spec for 
ComThetrainline).
3. Log errors and integrate monitoring systems(Sentry).
