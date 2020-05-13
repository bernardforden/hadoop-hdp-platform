# required libs
require 'rubygems'
require 'json'
require 'sinatra'
require './models/session.rb'
require './models/error.rb'
require './databases/redis.rb'
require './databases/hbase.rb'
require 'digest/md5'

   
# Sessions controller class   
class Sessionmgr
# Constants definition
  SESSIONS_TABLE_NAME = 'sys_authorization'
  APPLICATION_CF = 'app'
  SESSIONS_CF = 's'
  SCOPE_CF = 'scp'
  APP_PK_CL = 'private_key'
# Constructer
def initialize
  @RedisHandle = RedisHandle.new
  @HbaseHandle = HBaseHandle.new(SESSIONS_TABLE_NAME)
end
# Destructer/closing all the connections
def close_connection
  @RedisHandle.close_connection()
  @HbaseHandle.close_connection()
end
## Sessions management feature 
# Create new session
# @param application_id [String]
# @param secure_hash_code [String]
# @return json object which include session_id and max_age if success or error if not.
def create(application_id, private_hash_code)
    if isGranted(application_id, private_hash_code)
      session = Session.new(application_id)
      if @HbaseHandle.add_cell(session.application_id, SESSIONS_CF, session.session_id, session.to_json_hbase)
         @RedisHandle.add_pair_with_expire(session.session_id, session.to_json_redis, session.max_age) 
        session.to_json_sort
      else error = Error.new(403, "Your request is not successed", "We are not able to create new session at the moment!") end
    else error = Error.new(403, "Your request is not granted!", "Your pair of application_id and private key is not valid!") end 
end
# Delete a session
# @param application_id [String]
# @param session_id [String]
# @return error [Error] if operation failed.
def delete(application_id, session_id)
  if status(application_id,session_id) == 200
    @RedisHandle.delete_pair session_id
    @HbaseHandle.drop_column(application_id, SESSIONS_CF, session_id)
  else error = Error.new(404, "Invalid session_id", "Your session came with a wrong id or expired") end  
end
# Extend a session
# @param session_id [String]
# @param extend_time [int]
# @return 
def extend(session_id, extend_time)
end
# Check status of a session
# @param application_id [String]
# @param session_id [String]
# @return 200 if session is active, 404 error if not
def status(application_id, session_id)
  if (@RedisHandle.is_key_exist(session_id))
    200
  else
    begin
    session_info = @HbaseHandle.get_cell_value(application_id, SESSIONS_CF, session_id)
    session_info_hash = JSON.parse(session_info)
    rescue
      return error = Error.new(404, "Invalid session_id", "Your session came with a wrong id")
    end
    if ((Time::now.to_i - Time.parse(session_info_hash['create_date']).to_i) < session_info_hash['max_age'])
      @RedisHandle.add_pair_with_expire(session_id, session_info, session_info_hash['max_age'] - (Time::now.to_i - Time.parse(session_info_hash['create_date']).to_i))
      200
    else
      error = Error.new(404, "Invalid session_id", "Your session was expired")
    end
  end
end
# Verify scope of a session
# @param request_uri [String]
# @param application_id [String]
# @param session_id [String]
# @param secure_hash_code [String]
def verify_scope(request_uri, application_id, session_id, secure_hash_code)
  status = status(application_id, session_id)
  if status.is_a? Error
    puts "errorsasdasdasdas"
    return status
  end
  puts @RedisHandle.get_value(session_id).class
  puts @RedisHandle.get_value(session_id)
  secure_hash_key = JSON.parse(@RedisHandle.get_value(session_id))['secure_hash_key']
  if(Digest::MD5.hexdigest(request_uri+secure_hash_key).eql?(secure_hash_code))
    sub_uris = request_uri.split(application_id)
    if (@HbaseHandle.is_column_exist(application_id, SCOPE_CF, Digest::MD5.hexdigest(sub_uris[0] + application_id)))
      200
    else
      error = Error.new(404, "Invalid request!", "Scope is not valid")      
    end
  else
    error = Error.new(404, "Invalid request!", "Secure_hash_code is wrong")
  end
end
# Get information of a session
# @param application_id [String]
# @param session_id [String]
# @return session infor or error [Error] if operation failed.
def info(application_id, session_id)
    if (@RedisHandle.is_key_exist(session_id))
      (JSON.parse(@RedisHandle.get_value(session_id)).merge :session_id => session_id).to_json
    elsif @HbaseHandle.is_column_exist(application_id,SESSIONS_CF,session_id)
      @HbaseHandle.get_cell_value(application_id, SESSIONS_CF, session_id)
    else
      return Error.new(404, "Invalid session_id", "Your session came with a wrong id or expired")
    end
end
# Check pair of application_id and secure_hash_code
# @param application_id [String]
# @param secure_hash_code [String]
# @return true if pair is corrected or false if not.
def isGranted(application_id, private_hash_code)
  if (@RedisHandle.is_pair_exist(application_id, private_hash_code)) 
    true
  else
    application_private_key = @HbaseHandle.get_cell_value(application_id, APPLICATION_CF, APP_PK_CL)
    if(Digest::MD5.hexdigest(application_id+application_private_key).eql?(private_hash_code))
      @RedisHandle.add_pair(application_id,private_hash_code)
      true
    else
      false
    end
  end
end
end