require 'uri'
require 'open3'

module ActiveCim

  class ConnectorError < StandardError; end # :nodoc:
  
  # Cim class not found
  class CimClassNotFound < ConnectorError; end # :nodoc:

  # Connector or provider does not implement functionality
  class NotImplemented < ConnectorError; end # :nodoc:
  
  # The connector class allows ActiveCim::Base to
  # communicate with the actual CIMOM,
  # it is abstracted so different CIM client libraries could
  # be used, including Web services management
  #
  # to implement a connector you need to inherit from this
  # class and implement the following methods
  #
  # each_key
  # each_property
  # each_class_name
  # each_instance
  # instance
  #
  # See the documentation of each method
  #
  class Connector

    DEFAULT_CONNECTOR = :wbem_cli

    # iterates over properties
    # that identify an instance
    # of the given CIM class
    def each_key(klass_name)
      raise NotImplemented
    end

    # iterates over properties
    def each_property(klass_name)
      raise NotImplemented
    end

    # iterates over all available
    # CIM classes
    def each_class_name
      raise NotImplemented
    end

    # iterates over all instances of
    # a CIM class
    # returns a hash with the key values
    def each_instance(klass_name)
      raise NotImplemented
    end

    # gets an instance
    # returns a hash with the properties
    # FIXME should pass a hash with keys
    def instance(path)
      raise NotImplemented
    end
    
    def initialize(site)
      raise ArgumentError, 'Missing site URI' unless site
      @user = @password = nil
      self.site = site
      #self.format = format
    end
 
    # Set URI for remote service.
    def site=(site)
      @site = site.is_a?(URI) ? site : URI.parse(site)
      @user = URI.decode(@site.user) if @site.user
      @password = URI.decode(@site.password) if @site.password
    end

    def site
      @site
    end
    
    # Set user for remote service.
    def user=(user)
      @user = user
    end
 
    # Set password for remote service.
    def password=(password)
      @password = password
    end

    # factory method
    def self.create(site, type = DEFAULT_CONNECTOR)
      case type
        when :wbem_cli
          WbemCliConnector.new(site)
        else
          raise "Unknown connector type"
      end
    end
    
  end
end

require 'active_cim/wbem_cli_connector'
