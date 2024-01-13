#TO-DO: Cache session_id based on society, user_id and a random string, it should be nested with society aoa_number, user_id
#TO-DO: Delete any entry for user in society if no active sessions are present
require_relative "./../../lib/db_adapters/cache_adapter.rb"
require_relative "./../../lib/authentication/jwt.rb"

class Session < ApplicationRecord
  self.abstract_class = true
  include CacheAdapter
  include Token

  def self.store_session_id(session_id, aoa_number, user_id)
    user_id = user_id.to_s
    society_cache = Cache.sfetch(aoa_number)
    if society_cache.blank?
      society_cache = {user_id => {"session_id" => session_id, "last_accessed" => DateTime.now.to_i.to_s}}.to_json
      Cache.sadd(aoa_number, society_cache)
      return
    end

    new_society_cache = JSON.parse(Cache.sfetch(aoa_number).first)
    new_society_cache[user_id] = {"session_id" => "", "last_accessed" => DateTime.now.to_i.to_s} if new_society_cache[user_id].blank?
    return if new_society_cache[user_id]["session_id"].eql?(session_id)

    new_society_cache[user_id]["session_id"] = session_id
    Cache.delete(aoa_number)
    Cache.sadd(aoa_number, new_society_cache.to_json)
  end

  def self.check_session_access(session_id, session_id_hash)
    #TO-DO: check in cache, session timeout
    #check in cache along with session timeout and if valid, update session id timestamp and return true, else delete entry in cache and return false
    byebug
    aoa_number = session_id_hash[""]
    update_session_id(session_id)
  end

  def self.delete_session(session_id)
    byebug
  end

  private

  def self.update_session_id(session_id)
    byebug
  end

end
