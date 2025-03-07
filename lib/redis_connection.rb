# frozen_string_literal: true

require "redis"

class RedisConnection
  def self.instance
    @instance ||= Redis.new(
      host: ENV["REDIS_HOST"] || "localhost",
      port: ENV["REDIS_PORT"] || 6379
    )
  end
end
