require File.join(File.dirname(__FILE__), 'test_helper')
require 'active_cim/connector_adapter'
require 'active_cim/test/macros'
require 'active_cim/wbem_cli_connector'
require 'pp'



class TC_WbemCliConnectorTest < Test::Unit::TestCase
  include ActiveCim::Test::Macros
  
  context "connector" do
    setup do
      @connector = ActiveCim::ConnectorAdapter.create(:wbem_cli)
    end

    should_behave_like_a_connector
  end
  
end
