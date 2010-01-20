require File.join(File.dirname(__FILE__), 'test_helper')
require 'active_cim/connector_adapter'
require 'active_cim/test/macros'
require 'active_cim/sfcc_connector'
require 'pp'


class TC_SfccConnectorTest < Test::Unit::TestCase
  include ActiveCim::Test::Macros
  
  def setup
    @connector = ActiveCim::ConnectorAdapter.create(:sfcc)
  end

  should_behave_like_a_connector
  
end
