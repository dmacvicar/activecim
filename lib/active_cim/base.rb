require 'rubygems'
require'activesupport'
require 'uri'
require 'pp'

#
# ActiveRecord like access for CIM data
#
# class Linux_EthernetPort < ActiveCim::Base
#  self.site = "http://localhost/root/cimv2"
# end
#
# ports = Linux_EthernetPort.find(:all)
#
module ActiveCim
  
  # ActiveCim::Base is the base class for CIM models
  # you want to proxy in your applications
  class Base
  
    class << self

      # returns the connector we are using
      # if refresh is true
      def connector(refresh = false)        
        if defined?(@connector) || superclass == Object
          if refresh || @connector.nil?
            connector = Connector.create
          end
          @connector
        else
          superclass.connector
        end
      end

      # sets a new connector
      def connector=(conn)
        @connector = conn
        @connector.user = user if user
        # @connector.password = password if password
        # @connector.timeout = timeout if timeout
      end          
      
      # the URI of the CIM server we are connecting to
      def site
        if defined?(@site)
          @site
        elsif superclass != Object && superclass.site
          superclass.site.dup.freeze
        end
      end

      # sets the URI of the CIM server we are connecting to
      def site=(site)
        @connector = nil
        if site.nil?
          @site = nil
        else
          @site = create_site_uri_from(site)
          @user = URI.decode(@site.user) if @site.user
          @password = URI.decode(@site.password) if @site.password
        end
      end
 
      # User authentication for the CIMOM. Not used yet
      def user
        # Not using superclass_delegating_reader. See +site+ for explanation
        if defined?(@user)
          @user
        elsif superclass != Object && superclass.user
          superclass.user.dup.freeze
        end
      end
    
      # Sets the \user authentication for the CIMOM. Not used yet
      def user=(user)
        @connector = nil
        @user = user
      end

      # CIM class name this model represents. By default
      # it is taken from the ruby class name
      #
      # Analog to element name in the REST world
      def cim_class_name
        if defined?(@cim_class_name)
          @cim_class_name
        end
        to_s
      end

      # Sets the \cim_class_name
      def cim_class_name=(classname)
        @cim_class_name = classname
      end
      
      # Creates a new instance with its attributes
      def create(attributes = {})
        self.new(attributes).tap {}
      end

      # Accepts a URI and creates the site URI from that.
      def create_site_uri_from(site)
        site.is_a?(URI) ? site.dup : URI.parse(site)
      end

      # Goes from CimLikeField to ruby_like_fields
      # FIXME move elsewhere
      def rubyize_fields(fields)
        hsh = Hash.new
        fields.each do |key,val|
          hsh.store(rubyize(key.to_s).to_sym, val)
        end
        hsh
      end

      # Goes from ruby_like to CimLike
      # FIXME move elsewhere
      def rubyize(name)
        name.underscore
      end

      # Goes from ruby_like to CimLike
      # FIXME move elsewhere      
      def cimize_fields(fields)
        hsh = Hash.new
        fields.each do |key,val|
          hsh.store(cimize(key.to_s).to_sym, val)
        end
        hsh
      end

      # Goes from ruby_like to CimLike
      # FIXME move elsewhere
      def cimize(name)
        name.camelize.gsub(/Id/, "ID")
      end
      
      # Core method for finding instances. Used similarly to Active Record's +find+ method.
      #
      # ==== Arguments
      # The first argument is considered to be the scope of the query. That is, how many
      # resources are returned from the request. It can be one of the following.
      #
      # * <tt>:one</tt> - Returns a single instance
      # * <tt>:first</tt> - Returns the first instance found.
      # * <tt>:last</tt> - Returns the last instance found.
      # * <tt>:all</tt> - Returns every instance that matches the request.
      #
      # ==== Examples
      # ports = Linux_EthernetPort.find(:all)
      #
      def find(*arguments)
        scope = arguments.slice!(0)
        options = arguments.slice!(0) || {}
 
        case scope
          when :all then find_every(options)
          when :first then find_every(options).first
          when :last then find_every(options).last
          when :one then find_one(options)
          else find_single(scope, options)
        end
      end

      private
      # Find every resource
      def find_every(options)
        coll = []
        connector.each_instance("#{site}:#{cim_class_name}") do |ins_path|
          instance = connector.instance(ins_path)
          coll << rubyize_fields(instance)
        end
        instantiate_collection(coll)
      end
 
      # Find a single instance
      def find_one(options)
        raise "Not implemented"
      end
 
      def instantiate_collection(collection)
          collection.collect! { |record| instantiate_record(record) }
      end
      
      # takes the properties and creates a record from it
      # note that those are the key properties
      def instantiate_record(record)
          new(record).tap do |resource|
          end
        end
    end

    # constructor    
    def initialize(attributes = {})
      @attributes = {}
      @prefix_options = {}
      load(attributes)
    end

    attr_accessor :attributes

    def load(attributes)
      raise ArgumentError, "expected an attributes Hash, got #{attributes.inspect}" unless attributes.is_a?(Hash)
      attributes.each do |key, value|
        @attributes[key.to_s] =
          case value
            when Array
              raise "Not implemented"
              #resource = find_or_create_resource_for_collection(key)
              #value.map { |attrs| attrs.is_a?(String) ? attrs.dup : resource.new(attrs) }
            when Hash
              raise "Not implemented"
              #resource = find_or_create_resource_for(key)
              #resource.new(value)
            else
              value.dup rescue value
          end
      end
      self
    end
    
    def connector(refresh = false)
      self.class.connector(refresh, opts)
    end

    def connector=(conn)
      self.class.connector = conn
    end
    
    def new?
      id.nil?
    end
    alias :new_record? :new?
 
    # Gets the <tt>\id</tt> attribute of the resource.
    def id
      @id.to_s
      #attributes[self.class.primary_key]
    end
 
    # Sets the <tt>\id</tt> attribute of the resource.
    def id=(id)
      @id = id
      #object_id
      #attributes[self.class.primary_key] = id
    end
     
    def to_param
      id && id.to_s
    end

    # A method to \reload the attributes of this object from the remote web service.
    #
    # ==== Examples
    # my_branch = Branch.find(:first)
    # my_branch.name # => "Wislon Raod"
    #
    # # Another client fixes the typo...
    #
    # my_branch.name # => "Wislon Raod"
    # my_branch.reload
    # my_branch.name # => "Wilson Road"
    def reload
      self.load(self.class.find(to_param, :params => @prefix_options).attributes)
    end

    # A method to determine if an object responds to a message (e.g., a method call). In Active Resource, a Person object with a
    # +name+ attribute can answer <tt>true</tt> to <tt>my_person.respond_to?(:name)</tt>, <tt>my_person.respond_to?(:name=)</tt>, and
    # <tt>my_person.respond_to?(:name?)</tt>.
    def respond_to?(method, include_priv = false)
      method_name = method.to_s
      if attributes.nil?
        return super
      elsif attributes.has_key?(method_name)
        return true
      elsif ['?','='].include?(method_name.last) && attributes.has_key?(method_name.first(-1))
        return true
      end
      # super must be called at the end of the method, because the inherited respond_to?
      # would return true for generated readers, even if the attribute wasn't present
      super
    end

    def exists?
      !new? && self.class.exists?(to_param, :params => prefix_options)
    end
    
    def to_xml(options={})
      attributes.to_xml({:root => self.class.element_name}.merge(options))
    end
    
    def as_json(options = nil)
      attributes.as_json(options)
    end
    
    def cim_class_name(options = nil)
      #self.class.cim_class_name(to_param, options || prefix_options)
      self.class.cim_class_name
    end

    def method_missing(method_symbol, *arguments) #:nodoc:
      method_name = method_symbol.to_s
 
      case method_name.last
      when "="
        attributes[method_name.first(-1)] = arguments.first
      when "?"
        attributes[method_name.first(-1)]
      else
        attributes.has_key?(method_name) ? attributes[method_name] : super
      end
    end
    
  end
  
end
