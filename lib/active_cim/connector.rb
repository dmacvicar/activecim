require 'uri'
require 'open3'
require 'active_cim/error'
require 'active_cim/cim/object_path'
require 'enumerator'

module ActiveCim

  class ConnectorError < StandardError; end # :nodoc:
  
  # Cim class not found
  class CimClassNotFound < ConnectorError; end # :nodoc:

  # Connector or provider does not implement functionality
  class NotImplemented < ConnectorError; end # :nodoc:
  
  # The connector class allows ActiveCim::Base to
  # communicate with the actual CIMOM,
  # it is abstracted so different CIM client libraries could
  # be used, including CIMOM client libraries, native
  # ruby WBEM implementations, or accessing CIM via Web services
  # management.
  #
  # In order to implement a connector you need to inherit from this
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
    def each_key(klass_path)
      raise ErrorNotSupported
    end

    # iterates over properties
    def each_property(path)
      raise NotImplemented
    end

    # iterates over all available
    # CIM classes object paths
    def each_class_name(path)
      begin
        return Enumerable::Enumerator.new(@connector, :each_class_name, path)
      rescue NoMethodError
        raise ErrorNotSupported
      end
    end

    # iterates over all instances of
    # a CIM class
    # yielding the instance object path
    def each_instance_name(path)
      begin
        return Enumerable::Enumerator.new(@connector, :each_instance_name, path)
      rescue NoMethodError
        raise ErrorNotSupported
      end
    end

    # invokes a CIM method named +method+ with +argsout+
    # on the CIM instance defined by +path+
    #
    # output arguments are merged in the argsout Hash
    # if it is not nil, or a new hash is created if the
    # Hash is nil
    def invoke_method(path, method, argsin, argsout=nil)
      begin
        argsout = {} if argsout.nil?
        @connector.invoke_method(path, method, argsin, argsout)
      rescue NoMethodError
        raise ErrorNotSupported
      end
    end
    
    # gets an instance
    # returns a hash with the properties
    def instance(object_path)
      raise ErrorNotSupported
    end
    
    def initialize(connector)
      @connector = connector
    end

    def connector
      @connector
    end
    
    # factory method
    def self.create(type = DEFAULT_CONNECTOR)
      case type
        when :wbem_cli
          self.new(WbemCliConnector.new)          
        else
          raise "Unknown connector type"
      end
    end
    
  end
end

require 'active_cim/wbem_cli_connector'
