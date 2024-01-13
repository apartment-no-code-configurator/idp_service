module CacheAdapter
  class Cache

    def self.connection
      Rails.cache.redis
    end

    def self.sfetch(key)
      return_value = nil
      connection.with do |conn|
        return_value = conn.smembers(key)
      end
      return_value
    end

    def self.sadd(key, value)
      connection.with do |conn|
        conn.sadd?(key, value)
      end
    end

    def self.delete(key)
      connection.with do |conn|
        conn.del(key)
      end
    end

    def self.supdate(key, old_value, new_value)
      connection.with do |conn|
        conn.srem(key, old_value)
        conn.sadd(key, new_value)
      end
    end

  end
end
