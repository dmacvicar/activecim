require 'uri'
require 'active_support/core_ext'

module ActiveCim

  module Cim

    # CIM object path
    class ObjectPath

      def ==(object_path)
        to_s == object_path.to_s
      end
      
      # parses an ObjectPath from a string
      def self.parse(string)
        ActiveCim::Cim::ObjectPath.new(string)
      end

      # Creates a new object path from an URI or a string
      # representation of an URI
      def initialize(uri)
        @class_name = nil
        case uri
          when String then @uri = URI.parse(URI.escape(uri))
          when URI then @uri = uri
        end

        @scheme = @uri.scheme || 'http'
        @port = @uri.port || 5988
        @host = @uri.host || 'localhost'

        @namespace, rest = @uri.path.split(':', 2)
        @namespace = @namespace[1, @namespace.size] if @namespace[0,1] == '/'
        parse_object_name(rest)
      end

      def parse_object_name(string)        
        class_name_str, rest = string.split('.', 2) if string
        @class_name = class_name_str.to_sym if class_name_str
        
        @keys = {}
        if rest
          rest.chomp.split(',').map do |x|
            k,v = x.split('=')
            @keys[k.to_sym] = URI.unescape((v || '')).gsub(/"/, "")
          end
        end
      end

      # returns the object path for the class of the object
      # path
      # op = ObjectPath.parse("http://localhost/root/cimv2")
      # op.and_name('Linux_ComputerSystem.Name="foo"')
      # => http://localhost/root/cimv2:Linux_ComputerSystem.Name="foo"
      #
      # op.class_path
      # => http://localhost/root/cimv2:Linux_ComputerSystem
      def class_path
        op = self.clone
        op.keys = {}
        op
      end
      
      # returns the object path for the named class and keys
      # in the current namespace
      #
      # op = ObjectPath.parse("http://localhost/root/cimv2")
      # op.and_name('Linux_ComputerSystem.Name="foo"').to_s
      # => http://localhost/root/cimv2:Linux_ComputerSystem.Name="foo"
      def and_name(name)
        op = self.clone
        op.parse_object_name(name)
        op
      end
      
      # returns the object path for the named class
      # in the current namespace
      #
      # op = ObjectPath.parse("http://localhost/root/cimv2")
      # op.and_class('Linux_ComputerSystem').to_s
      # => http://localhost/root/cimv2:Linux_ComputerSystem
      def and_class(name)
        op = self.clone
        op.class_name = name.to_s.to_sym
        op
      end

      # set the class name
      def class_name=(name)
        @class_name = name.to_s.to_sym
      end
      
      # alias for and_class(name)
      def /(name)
        and_class(name)
      end

      # returns the instance object path for the given keys
      #
      # op = ObjectPath.parse("http://localhost/root/cimv2")
      # op.and_class('Linux_ComputerSystem').with(:Name => 'foo')
      # => http://localhost/root/cimv2:Linux_ComputerSystem.Name="foo"
      def with(keys)
        op = self.clone
        op.keys = keys
        op
      end

      # set the instance keys
      def keys=(keys)
        @keys = keys
      end
      
      # object path scheme ie: 'http'
      def scheme
        @scheme
      end

      # object path port ie: '5988'
      def port
        @port
      end

      # object path host ie: 'host'
      def host
        @host
      end

      # gets the object name. Depending on the type of
      # CIM element referenced, this may be either a class name
      # or a qualifier type name
      def object_name        
        "#{class_name}#{instance_suffix_to_s}"
      end

      # gets the class name
      def class_name
        @class_name
      end
      
      # returns the keys if the referenced object is an
      # instance
      def keys
        @keys
      end
      
      # the objects namespace
      def namespace
        if @namespace.nil?
          ns = URI.unescape(@uri.path.split(':', 2)[0])
          if ns[0,1] == '/'
            @namespace = ns[1, ns.size]
          else
            @namespace = ns
          end
        end
        @namespace
      end

      # true if references a class
      def class?
        !object_name.empty? and keys.empty?
      end

      # true if references an instance
      def instance?
        !object_name.empty? and not keys.empty?
      end      

      # string representation of the object path
      def to_s
        "#{scheme}://#{host}:#{port}/#{namespace}#{object_name_suffix}"
      end

      private

      def object_name_suffix
        return '' if class_name.blank?
        ":#{object_name}"
      end
      
      def instance_suffix_to_s
        return '' if keys.blank?
        ".#{(keys.map { |k,v| "#{k}=\"#{v}\"" }).sort.join(',')}"
      end
      
    end
  end
end
    
