# required libs
require 'rubygems'
require 'redis'
require 'json'
require './models/session.rb'

# Redis adapter class 
class RedisHandle
  
  # Constants setting
  # Redis host
  REDIS_HOST = '172.27.5.5'
  # Redis port
  REDIS_POST = 6379
  # Redis user
  REDIS_USER = 'user'
  # Redis password
  REDIS_PASSWORD = 'password'
  # Redis database number
  REDIS_DB_NUM = '7'
  
  # Contructor/Create new redis adapter with defined constants REDIS_HOST and REDIS_POST
  def initialize
    @redis = Redis.new(:host => REDIS_HOST, :port => REDIS_POST)
    @redis.select REDIS_DB_NUM
  end
  
  # Destructor/Close connection
  def close_connection
    @redis.quit()    
  end
  
  # Add pair into redis database
  # @param key [String], value [String]
  def add_pair(key, value)
    @redis.set(key, value)
  end
  
  # Get associated value from key
  # @param key [String]
  def get_value (key)
    @redis.get key
  end
  
  # Checking if the key is exist
  # @param key [String]
  def is_key_exist(key)
    (@redis.exists key) ? true : false 
  end
  
  # Checking if the pair is exist
  # @param key [String], value [String] 
  def is_pair_exist(key, value)
    ((@redis.get key).eql? value) ? true : false 
  end    
  
  # Add pair include expire time
  # @param key [String], value [String], expire_time [String]   
  def add_pair_with_expire(key, value, expire_time)
     @redis.set(key, value)
     @redis.expire(key, expire_time) 
  end
 
  # Delete pair from redis database
  # @param key [String]   
  def delete_pair(key)
    @redis.del key      
  end
  
end


