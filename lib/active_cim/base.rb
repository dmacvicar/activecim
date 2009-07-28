
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
      self.new(attributes).tap { |resource| resource.save }
    end
    
  end
end
end
