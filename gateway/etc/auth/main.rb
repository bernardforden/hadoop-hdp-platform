# Hadoop Authorization Service

## required libs
require 'rubygems'
require 'sinatra'
require 'json'
require './controllers/sessionmgr.rb'

## sinatra web server configuration block
configure do
  set :server, %w[thin webrick]
  set :bind, '0.0.0.0'
  set :port, 1605
  set :app_file, __FILE__
end

## Firstly set the content type to json
before do
  content_type :json  
end


## request handling
# POST : Create new session request
post '/auth/session'  do
  puts "post"
  request.body.rewind
  data = JSON.parse request.body.read #paser json body into hash
  puts data
  sessionmgr = Sessionmgr.new
  res_obj = sessionmgr.create(data['application_id'],data['private_hash_code'])
  sessionmgr.close_connection()
  (res_obj.is_a? Error) ? (status res_obj.error ; res_obj.to_json) : (puts res_obj ; res_obj)
end

# HEAD : Checking session scope 
head '/auth/session/scope' do
  puts "head scope" ;
  puts "request_uri: "+params[:request_uri]
  puts "secure_hash_code: "+params[:secure_hash_code]
  puts "app_id: " + request.cookies['application_id']
  puts "session_id: " + request.cookies['session_id']
  sessionmgr = Sessionmgr.new
  res_obj = sessionmgr.verify_scope(params[:request_uri], request.cookies['application_id'], request.cookies['session_id'], params[:secure_hash_code])
  sessionmgr.close_connection 
  (res_obj.is_a? Error) ? (404) : (200) 
end

# HEAD : Checking session status is valid or not. Only return 200 if session is alive
head '/auth/session/:session_id' do
  puts "head session" ; puts "app_id: "+request.cookies['application_id']+ "   "+"session_id: "+params[:session_id]
  sessionmgr = Sessionmgr.new
  res_obj = sessionmgr.status(request.cookies['application_id'], params[:session_id])
  sessionmgr.close_connection()
  (res_obj.is_a? Error) ? (404) : (200) 
end

# GET : Get session infor content
get '/auth/session/:session_id' do
  puts "get" ; puts "app_id: "+request.cookies['application_id']+ "   "+"session_id: "+params[:session_id]
  request.body.rewind
  sessionmgr = Sessionmgr.new
  res_obj = sessionmgr.info(request.cookies['application_id'], params[:session_id])
  sessionmgr.close_connection()
  (res_obj.is_a? Error) ? (status res_obj.error ; res_obj.to_json) : (puts res_obj ; res_obj)
end

# DELETE : delete session
delete '/auth/session/:session_id' do
  puts "delete" ; puts "app_id: "+request.cookies['application_id']+ "   "+"session_id: "+params[:session_id]
  sessionmgr = Sessionmgr.new
  res_obj = sessionmgr.delete(request.cookies['application_id'], params[:session_id])
  sessionmgr.close_connection()
  if res_obj.is_a? Error
    status res_obj.error ; res_obj.to_json  end 
end


## Error handling
# Internal error 500
error do
  {"error code" => env['sinatra.error'].code, "error name" => env['sinatra.error'].name, "error message" => env['sinatra.error'].message}.to_json
end




