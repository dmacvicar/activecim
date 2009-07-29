
require 'test_helper'
require 'active_cim/connector'
require 'pp'

class TC_MyTest < Test::Unit::TestCase
  # def setup
  # end

  # def teardown
  # end

  def test_connector_wbem_cli

    # TODO mocha these tests
    
    conn = ActiveCim::Connector.create("http://localhost/root/cimv2", :wbem_cli)

    cim_classes = []
    conn.each_class_name do |name|
      cim_classes << name
    end
    assert_equal 74, cim_classes.size
    
    # unknown class
    assert_raise ActiveCim::CimClassNotFound do
      conn.each_instance_path('NonExistantClass')
    end
          
    instances = []
    conn.each_instance_path('CIM_EthernetPort') do |i|
      instances << i
    end
    assert_equal 2, instances.size

    #pp conn.instance(instances.first)    
    #pp instances
    
    
  end
  
  #def test_fail
  #  assert(false, 'Assertion was false.')
  #end
end
