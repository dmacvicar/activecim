
require 'test_helper'
require 'active_cim/test_connector'
require 'pp'

URL = "http://localhost:5988/root/cimv2"

class Linux_EthernetPort < ActiveCim::Base
  self.site = URL
end

class TC_ActiveCim_TestConnector < Test::Unit::TestCase
  # def setup
  # end

  # def teardown
  # end

  def test_base

    data = test_data("test_connector")
    conn = ActiveCim::TestConnector.new(data)

    conn.each_class_name("#{URL}") do |name|
      conn.each_instance("#{URL}:#{name}") do |instance|
        #pp "peo " + instance
      end
    end

  end
  
end
