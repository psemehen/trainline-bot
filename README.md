Bot that triggers Trainline.
Technologies used: Ruby, linter(Standard), RSpec.

1. Make sure you have Ruby installed.
2. Install dependencies with the cmd `bundle install`
3. Bot responds to `ComThetrainline.find(from, to, departure_at)` in  `trainline_bot.rb` file.
By default, it runs with the following arguments: `ComThetrainline.find("Berlin Hbf", "Warszawa-Centralna", "#<DateTime: 2025-03-12T14:00:00+00:00 ((2456774j,22140s,0n),+0s,2299161j)>")`.

Space for improvements:
1. Leverage I18n for error messages.
2. Add caching(Redis/Memchached) for fetching location codes as they don't change frequently. This will reduce the load 
on Trainline, improve response times, and speed up the overall performance of the application.
3. Improve test coverage by adding more test cases.
4. Log errors and integrate monitoring systems(Sentry).
