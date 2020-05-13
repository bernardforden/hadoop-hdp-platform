#require components
require 'rubygems'
require  'json'


# Present data model for a session.
#
class Session
  # List constant
  TIMEOUT = 3600
  
  # Status of a session
  STATUS = {"na" => 0, "alive" => 1, "killed" => 2}
  
  # Create new session base on application_id and secure_hash_code
  def initialize(application_id)
    @application_id = application_id
    @secure_hash_key = SecureRandom.uuid
    @session_id = SecureRandom.uuid
    @create_date= Time::now
    @max_age = rand(TIMEOUT..(TIMEOUT*2))
    @modify_time = Time::now
    @last_used = Time::now
    @status = STATUS["alive"]
  end
  
  # Attributies get/set
  attr_reader :application_id, :secure_hash_code,  :session_id, :create_date,  :max_age, :modify_time, :last_used
  attr_accessor :application_id, :secure_hash_code,  :session_id, :create_date,  :max_age, :modify_time, :last_used
  
  # Create json object which include "session_id" and "max_age" of session
  def to_json_sort
    JSON.generate({:session_id => @session_id, :max_age => @max_age, :secure_hash_key => @secure_hash_key})
  end
  
  # Create json object which include "application_id" , "secure_hash_code" , "create_date" , "max_age" , "modify_time" , "last_used" and "status" of session
  def to_json_redis
    JSON.generate({:application_id => @application_id, 
                   :secure_hash_key => @secure_hash_key,  
                   :create_date => @create_date,
                   :max_age => @max_age,
                   :modify_time => @modify_time,
                   :last_used => @last_used,
                   :status=> @status})    
  end
  
      # Create json object which include "application_id" , "secure_hash_code" , "create_date" , "max_age" , "modify_time" , "last_used" and "status" of session
  def to_json_hbase
    JSON.generate({:secure_hash_key => @secure_hash_key,
                   :create_date => @create_date,
                   :max_age => @max_age,
                   :modify_time => @modify_time,
                   :last_used => @last_used,
                   :status=> @status})    
  end 
end
