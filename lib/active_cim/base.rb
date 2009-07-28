require 'rubygems'
require'activesupport'

module ActiveCim
  # ActiveCim::Base
  class Base
  
    class << self

      def site
        if defined?(@site)
          @site
        elsif superclass != Object && superclass.site
          superclass.site.dup.freeze
        end
      end

      def site=(site)
        @connection = nil
        if site.nil?
          @site = nil
        else
          @site = create_site_uri_from(site)
          @user = URI.decode(@site.user) if @site.user
          @password = URI.decode(@site.password) if @site.password
        end
      end
 
      # Gets the \user for REST HTTP authentication.
      def user
        # Not using superclass_delegating_reader. See +site+ for explanation
        if defined?(@user)
          @user
        elsif superclass != Object && superclass.user
          superclass.user.dup.freeze
        end
      end
    
      # Sets the \user for REST HTTP authentication.
      def user=(user)
        @connection = nil
        @user = user
      end

      def cim_class_name
        if defined?(@cim_class_name)
          @cim_class_name
        end
        to_s
      end

      def cim_class_name=(classname)
        @cim_class_name = classname
      end
      

      def create(attributes = {})
        self.new(attributes).tap {}
      end
    
    end

    # constructor    
    def initialize(attributes = {})
      @attributes = {}
      @prefix_options = {}
      #load(attributes)
    end

    attr_accessor :attributes
    
    def new?
      id.nil?
    end
    alias :new_record? :new?
 
    # Gets the <tt>\id</tt> attribute of the resource.
    def id
      object_id
      #attributes[self.class.primary_key]
    end
 
    # Sets the <tt>\id</tt> attribute of the resource.
    def id=(id)
      #object_id
      #attributes[self.class.primary_key] = id
    end
     
    def to_param
      id && id.to_s
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
