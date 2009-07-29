require 'uri'

module ActiveCim

  class Connector

    def initialize(site)
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

    def site
      @site
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

  class WbemCliConnector < ActiveCim::Connector
    def initialize(site)
      super(site)
    end

    def initialize
      super("http://localhost/root/cimv2")
    end
    
    def run_wbem_cli(args)
      out = `wbemcli #{args}`
      # wbemcli does not exit with non zero so
      # raise if the exception message is shown
      if out[0] == '*'
        msg = out.split("\n")
      out
    end
      
    def each_class_name
      out = run_wbem_cli "ecnff #{site}"
      out.each_line do |line|
        yield line.split(':').last.chomp
      end
    end
    
  end
end
