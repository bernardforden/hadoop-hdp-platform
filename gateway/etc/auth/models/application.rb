#require components
require 'rubygems'
require  'json'


# Present data model for a application.
#
class Application
  # List constant
  
  # Status of a session
  STATUS = {"created" => 0, "registering" => 1, "registered" => 2, "locked" => 3, "normal" => 4}
  
  # Create new session base on application_id and secure_hash_code
  def initialize(args)
    if (args.length == 1)
      @application_id = SecureRandom.uuid
      @private_key = SecureRandom.uuid
      @certificate = SecureRandom.uuid
      @create_date = Time::now
      @secure_hash_key = rand(TIMEOUT..(TIMEOUT*2))
      @status = STATUS["created"]
      @scope = scope
    else
      @application_id = SecureRandom.uuid
      @private_key = SecureRandom.uuid
      @certificate = SecureRandom.uuid
      @create_date = Time::now
      @secure_hash_key = rand(TIMEOUT..(TIMEOUT*2))
      @status = STATUS["created"]
      @scope = scope      
    end
  end
  
  # Attributies get/set
  attr_reader :application_id, :private_key,  :certificate, :create_date,  :secure_hash_key, :status, :scope
  attr_accessor :application_id, :private_key,  :certificate, :create_date,  :secure_hash_key, :status, :scope
  
  
  # Create json object which include "application_id" , "secure_hash_code" , "create_time" , "max_age" , "modify_time" , "last_used" and "status" of session
  def to_json_redis
    JSON.generate({:private_key => @private_key, 
                   :certificate => @certificate,  
                   :create_date => @create_date,
                   :secure_hash_key => @secure_hash_key,
                   :status => @status,
                   :scope => @scope})    
  end 
end
