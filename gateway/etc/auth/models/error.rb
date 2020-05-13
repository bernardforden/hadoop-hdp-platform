# required libs
require 'rubygems'
require 'json'

# Present data model for a http error.
#
class Error
  
  # Create new error with error code, message and description
  # @param error [int]
  # @param message [String]
  # @param description [String]
  def initialize (error, message, description)
    @error = error;
    @message = message;
    @description = description;    
  end
  
  # Attributies get/set
  attr_reader :error, :message, :description
  attr_accessor :error, :message, :description
  
  # Generate json object of an error
  # @return json object which inlcude "error", "message" , "description"
  def to_json
    JSON.generate({:error => @error, :message => @message, :description => @description})
  end
    
end
