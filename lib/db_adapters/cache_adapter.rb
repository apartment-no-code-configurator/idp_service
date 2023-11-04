require "redis"

module CacheAdapters
  class RedisAdapter

    def initialize
      Redis.new #TO-DO: Add this from environment Redis.new(host: "HOST", port: "PORT", db: "0")
    end

  end
end
