
require 'test_helper'
require 'active_cim/base'

CIM_URI = "http://localhost:5988/root/cimv2"

class Linux_EthernetPort < ActiveCim::Base
  self.site = CIM_URI
end

class TC_ActiveCim_Base < Test::Unit::TestCase
  # def setup
  # end

  # def teardown
  # end

  def test_base

    return
    ports = Linux_EthernetPort.find(:all)
    #pp ports

    assert_nothing_raised do
      ports.each do |port|
        #puts port.id
        port.device_id
        port.system_name
      end
    end
    
  end
  
end
