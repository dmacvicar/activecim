require 'uri'
require 'open3'
require 'active_cim/connector_adapter'
require 'nokogiri'

#wbemcli cm 'http://localhost:5988/root/cimv2:Linux_OperatingSystem.CSCreationClassName="Linux_ComputerSystem",CSName="piscola.suse.de",CreationClassName="Linux_OperatingSystem",Name="piscola.suse.de"' 'execCmd.cmd="cat /etc/SuSE-release"'
module ActiveCim
   
  class WbemCliConnector
    
    # Connector API
    
    def class_names(path)
      Enumerable::Enumerator.new(self, :each_class_name, path)
    end

    def instance_names(path)
      Enumerable::Enumerator.new(self, :each_instance_name, path)
    end

    def class_properties(path)
      property_types(path).keys
    end        

    # get instance given the object path
    def instance_properties(object_path)
      out = run_wbem_cli('gi', '-nl', "#{object_path}")
      raise "Wrong output when retrieving #{object_path}" if out.empty?
      counter = 0
      properties = {}
      out.each_line do |line|
        # ignore firt line with object path
        if counter == 0
          counter += 1
          next
        end
        line.chomp!
        next if line.empty?
        #raise "Unknown output when retrieving #{object_path}" if line[0] == "-"
        k, v = line.split("=",2)
        k = $1 if k =~ /-(.+)/
        v = $1 if v =~ /\"(.*)\"/
        #raise ("Unknown output when retrieving key in #{object_path") if key.blank?
        property_name = k.to_sym
        # types
        v = string_to_type(v, property_types(object_path.class_path)[property_name])
        properties.store(k.to_sym, v)
      end
      properties
    end

    def invoke_method(path, method, argsin, argsout)
      argsin_line = argsin.map {|k,v| "#{k}=\"#{v}\""}
      method_call = argsin.empty? ? "#{method}" : "#{method}.#{argsin_line}"
      out = run_wbem_cli('cmx', "#{path}", method_call )

      doc = Nokogiri::XML.parse(out)
      doc.xpath("//PARAMVALUE").each do |node|
        param_name = node.attributes['NAME'].text.to_sym
        param_value = string_to_type(node.xpath("./VALUE").first.text, node.attributes['PARAMTYPE'].text.to_sym)
        argsout[param_name] = param_value
      end
      doc.xpath("//RETURNVALUE").each do |retnode|
        val_str = retnode.xpath("./VALUE").first.text
        return string_to_type(val_str, retnode.attributes['PARAMTYPE'].text.to_sym)
      end
      raise "No return value for #{method}"
    end
    
    # Implementation details and helpers

    def initialize
      @property_types = nil
    end

    def each_class_name(path)
      out = run_wbem_cli('ecn', "#{path}")
      out.each_line do |line|
        line.chomp!
        yield ActiveCim::Cim::ObjectPath.parse("#{path.scheme}://#{line}")
      end
    end

    def each_key(klass_path)
      # inneficient for now.. optimize later      
      class_def(klass_path, :types => true).each do |key,value|
        yield key.to_s[0..key.to_s.size-2].to_sym if key.to_s.last == "#"
      end
    end
    
    # iterates over each instance giving
    # on each iteration the fields needed to
    # identify the instance
    def each_instance_name(path)
      out = run_wbem_cli('ein', "#{path}")
      out.each_line do |line|
        line.chomp!
        yield ActiveCim::Cim::ObjectPath.parse("#{path.scheme}://#{line}")
      end
    end
 
    #private
    
    ## private methods ##

    def string_to_type(string, type)
      case type
      when :boolean
        string == "FALSE" ? false : true
      when :string
        string.to_s
      when :uint8, :uint16, :uint32, :uint64
        string.to_i
      when :datetime
        Time.now
      else
        nil
      end
    end
    
    # runs wbem gc to get class definition and
    # if :types => true also pass -t to get the
    # property types (key, array)
    def class_def(klass_path, opts ={})
      # if :types => true then we get the types
      args = []
      args << 'gc'
      args << '-t' if opts[:types]
      args << "#{klass_path}"
      out = run_wbem_cli(*args)
      raise "Bad response" if out.empty?
      # this stupid response does not have the dot between the class
      # name, so lets build it
      cn, path = out.chomp.split(" ")
      props = fields("#{path}")
    end

    def class_methods(path)
      method_types(path).keys
    end
    
    # private methods to discover properties and method
    # types and signatures
    def property_types(path)
      parse_types(path) if @property_types.nil?
      @property_types
    end

    def method_types(path)
      parse_types(path) if @method_types.nil?
      @method_types
    end

    def parameter_types(path, method_name=nil)
      parse_types(path) if @parameter_types.nil?
      method_name ? @parameter_types[method_name.to_sym] : @parameter_types
    end
    
    def parse_types(path)
      @property_types = {}
      @method_types = {}
      @parameter_types = {}
      out = run_wbem_cli('gcd', path)
      doc = Nokogiri::XML.parse(out)
      doc.xpath("//PROPERTY").each do |node|
        @property_types[node.attributes['NAME'].text.to_sym] = node.attributes['TYPE'].text.to_sym
      end
      doc.xpath("//METHOD").each do |node|
        method_name = node.attributes['NAME'].text.to_sym
        @method_types[method_name] = node.attributes['TYPE'].text.to_sym
        @parameter_types[method_name] = {}
        node.xpath("./PARAMETER").each do |param_node|
          param_name = param_node.attributes['NAME'].text.to_sym
          @parameter_types[method_name][param_name] = param_node.attributes['TYPE'].text.to_sym
        end
      end
    end
    
    # takes object path (only the path)
    # a map of properties_
    #
    # input: Linux_EthernetPort.SystemCreationClassName="Linux_ComputerSystem",SystemName="tarro",CreationClassName="Linux_EthernetPort",DeviceID="eth0"
    #
    # output: { :SystemCreationClassName = > "Linux_ComputerSystem", :SystemName => "tarro", :CreationClassName = > "Linux_EthernetPort", :DeviceID => "eth0"}
    # 
    def fields(path)
      fields = {}
      # split the part after the CIM class name
      pairs = path.chomp.split(',')
      pairs.each do |pair|
        key, value = pair.split('=')
        value = value.gsub(/"/, "") if not value.nil?
        fields[key.to_sym] = value
      end
      fields
    end
    
    # executes wbemcli and controls error handling
    def run_wbem_cli(*args)
      # quote args and join them
      args_s = args.unshift('wbemcli').map{ |x| "'#{x}'" }.join(' ')
      stdin, stdout, stderr = Open3::popen3(args_s)
      # wbemcli does not exit with non zero so
      # raise if the exception message is shown
      err = stderr.readlines
      # something bad happened?
      if not err.empty?
        err.reject! { |x| x == "*\n" }
        msg = err.map { |x| x =~ /^\* (.*)/; $1 }.join("\n")
        if msg =~ /CIM_ERR_INVALID_CLASS/
          raise CimClassNotFound
        else
          raise msg + " (when executing [ #{args_s} ] }" 
        end
      end
      # note, the output does not have URI schema
      # and the full line is not a valid URI
      stdout.read
    end

  end
  
end
