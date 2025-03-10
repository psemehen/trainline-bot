# frozen_string_literal: true

require "vcr"
require "webmock/rspec"

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.before_record do |interaction|
    interaction.response.body = interaction.response.body.force_encoding("UTF-8")
  end
end
