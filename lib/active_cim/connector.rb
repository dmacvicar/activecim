require 'uri'
require 'open3'

module ActiveCim

  class ConnectorError < StandardError; end # :nodoc:
  
  # Cim class not found
  class CimClassNotFound < ConnectorError; end # :nodoc:

  class Connector

    DEFAULT_CONNECTOR = :wbem_cli
    
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

    # factory method
    def self.create(site, type = DEFAULT_CONNECTOR)
      case type
        when :wbem_cli
          WbemCliConnector.new(site)
        else
          raise "Unknown connector type"
      end
    end
    
  end
end

require 'active_cim/wbem_cli_connector'
