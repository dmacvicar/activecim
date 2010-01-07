require 'uri'
require 'open3'
require 'active_cim/error'
require 'active_cim/cim/object_path'
require 'enumerator'

require 'active_cim/sfcc_connector'
require 'active_cim/wbem_cli_connector'

module ActiveCim

  # The connector adapter handles the communication between
  # ActiveCim and a concrete connector.
  #
  # Connectors allows ActiveCim::Base to communicate with the actual CIMOM.
  #
  # it is abstracted so different CIM client libraries could
  # be used, including CIMOM client libraries, native
  # ruby WBEM implementations, or accessing CIM via Web services
  # management.
  #
  # In order to implement a connector you need to create a
  # class and implement the following mandatory methods
  #
  # class_names(path)
  #  Should return an Enumerable with a ActiveCim::Cim::ObjectPath
  #  for each class in the namespace described by +path+.
  #
  # instance_names(path)
  #  Should return an Enumerable with a ActiveCim::Cim::ObjectPath
  #  for each instance for the class described by +path+.
  #
  # class_properties(path)
  #  Should return an Enumerable with one symbol per property
  #  on the class defined by +path+
  #
  # instance_properties(path)
  #  Should return the value of the properties as a Hash
  #  on the instance defined by +path+
  #
  # invoke_method(path, method, argsin, argsout)
  #  Should call the +method+ on instance defined by +path+ with
  #  +argsin+ as arguments and add the output arguments to +argsout+
  #  and return the method return value.
  #
  class ConnectorAdapter

    DEFAULT_CONNECTOR = :wbem_cli

    # Connector API
    
    def class_names(path)
      begin
        @connector.class_names(path)
      rescue NoMethodError
        raise ErrorNotSupported
      end
    end

    def instance_names(path)
      begin
        @connector.instance_names(path)
      rescue NoMethodError
        raise ErrorNotSupported
      end
    end
    
    def class_properties(path)
      begin
        @connector.class_properties(path)
      rescue NoMethodError
        raise ErrorNotSupported
      end
    end

    def instance_properties(path)
      begin
        @connector.instance_properties(path)
      rescue NoMethodError
        raise ErrorNotSupported
      end
    end

    def invoke_method(path, method, argsin, argsout=nil)
      begin
        argsout = {} if argsout.nil?
        @connector.invoke_method(path, method, argsin, argsout)
      #rescue NoMethodError
      #  raise ErrorNotSupported
      rescue Exception => e
        raise e
      end
    end
    
    # Implementation
    
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
        when :sfcc
          self.new(SfccConnector.new)
        else
          raise "Unknown connector type"
      end
    end
    
  end
end

