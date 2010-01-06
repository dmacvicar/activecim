require 'active_cim/connector'
require 'sfcc'

module ActiveCim
   
  class SfccConnector < Connector

    def initialize(uri)
      @uri = uri
      @client = Sfcc::Client.new
    end
    
    # goes through every class available on the server
    def each_class_name(path)
      return 
    end
  end
  
end
