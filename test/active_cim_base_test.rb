
require 'test_helper'
require 'active_cim/base'
require 'pp'

class Linux_EthernetPort < ActiveCim::Base
  self.site = "http://localhost:5988/root/cimv2"
end

class TC_ActiveCim_Base < Test::Unit::TestCase
  # def setup
  # end

  # def teardown
  # end

  def test_base
    
    ports = Linux_EthernetPort.find(:all)
    pp ports

    assert_nothing_raised do
      ports.each do |port|
        puts port.id
        port.device_id
        port.system_name
      end
    end
    
  end
  
end
