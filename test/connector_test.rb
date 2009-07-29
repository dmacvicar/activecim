
require 'test_helper'
require 'active_cim/connector'

class TC_MyTest < Test::Unit::TestCase
  # def setup
  # end

  # def teardown
  # end

  def test_connector_wbem_cli
    connector = ActiveCim::WbemCliConnector.new
    connector.site = "http://localhost/root/cimv2"

    connector.each_class_name do |name|
      puts name
    end
  end
  
  #def test_fail
  #  assert(false, 'Assertion was false.')
  #end
end
