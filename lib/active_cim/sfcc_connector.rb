
require 'rubygems'
require 'sfcc'

module ActiveCim
   
  class SfccConnector

    # Connector API
    
    def class_names(path)
      lazy_init(path)
      client.class_names(Sfcc::Cim::ObjectPath.new(path.namespace, ""), Sfcc::Flags::DeepInheritance).to_a.map { |op| path.and_class(op) }
    end

    def instance_names(path)
      lazy_init(path)
      client.instance_names(Sfcc::Cim::ObjectPath.new(path.namespace, path.class_name.to_s)).to_a.map { |op| path.and_name(op.to_s) }
    end

    def class_properties(path)
      lazy_init(path)
      cimclass = client.get_class(Sfcc::Cim::ObjectPath.new(path.namespace, path.class_name))
      Enumerable::Enumerator.new(cimclass, :each_property).map {|key, value| key}
    end

    def instance_properties(path)
      lazy_init(path)
      op = Sfcc::Cim::ObjectPath.new(path.namespace.to_s, path.class_name.to_s)      
      path.keys.each do |key, val|
        op.add_key(key.to_s, val)
      end
      instance = client.get_instance(op)
      instance.properties
    end

    def invoke_method(path, method, argsin, argsout)
      lazy_init(path)
      op = Sfcc::Cim::ObjectPath.new(path.namespace.to_s, path.class_name.to_s)
      path.keys.each do |key, val|
        op.add_key(key.to_s, val)
      end
      out = client.invoke_method(op, method.to_s, argsin, argsout)
    end
    
    # Implementation
    def initialize
      @client = nil
    end
    
    def client
      @client
    end
    
    def lazy_init(path)
      @client = Sfcc::Cim::Client.connect(path.to_s) if @client.nil?
    end
        
  end
  
end
