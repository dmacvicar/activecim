require 'uri'

module ActiveCim

  module Cim

    # CIM object path
    class ObjectPath
      
      # parses an ObjectPath from a string
      def self.parse(string)
        ActiveCim::Cim::ObjectPath.new(string)
      end

      # Creates a new object path from an URI or a string
      # representation of an URI
      def initialize(uri)
        case uri
          when String then @uri = URI.parse(URI.escape(uri))
          when URI then @uri = uri
        end

        @scheme = @uri.scheme || 'http'
        @port = @uri.port || 5988
        @host = @uri.host || 'localhost'

        @namespace, rest = @uri.path.split(':')
        @namespace = @namespace[1, @namespace.size] if @namespace[0,1] == '/'
        @class_name, rest = rest.split('.', 2) if rest
        
        @keys = {}
        if rest
          rest.chomp.split(',').map do |x|
            k,v = x.split('=')
            @keys[k.to_sym] = URI.unescape((v || '')).gsub(/"/, "")
          end
        end
      end

      # returns the object path for the named class
      # in the current namespace
      #
      # op = ObjectPath.parse("http://localhost/root/cimv2")
      # op.and_class('Linux_ComputerSystem').to_s
      # => http://localhost/root/cimv2:Linux_ComputerSystem
      def and_class(name)
        op = self.clone
        op.class_name = name
        op
        # self.class.parse("#{scheme}://#{host}:#{port}/#{namespace}:#{name}")
      end

      # set the class name
      def class_name=(name)
        @class_name = name
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
          ns = URI.unescape(@uri.path.split(':')[0])
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
        "#{scheme}://#{host}:#{port}/#{namespace}:#{object_name}"
      end

      private

      def instance_suffix_to_s
        return '' if keys.empty?
        ".#{(keys.map { |k,v| "#{k}=\"#{v}\"" }).sort.join(',')}"
      end
      
    end
  end
end
    
