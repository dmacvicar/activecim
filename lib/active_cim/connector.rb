
module ActiveCim

  class Connector

    def initialize(site)
      puts "MIERDA"
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
 
    # Set user for remote service.
    def user=(user)
      @user = user
    end
 
    # Set password for remote service.
    def password=(password)
      @password = password
    end    
  end

  class CliConnector < ActiveCim::Connector
    def initialize(site)
      super(site)
    end

    def initialize
      super("http://localhost/root/cimv2")
    end
    
    def run_wbem_cli(args)
      `wbemcli #{args}`
    end
      
    def each_class_name
      out = run_wbem_cli "ecn #{site}"
      out.each_line do |line|
        yield line
      end
    end
    
  end
end
