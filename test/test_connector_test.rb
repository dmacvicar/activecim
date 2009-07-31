
require 'test_helper'
require 'active_cim/test_connector'
require 'pp'

URL = "http://localhost:5988/root/cimv2"

class TC_ActiveCim_TestConnector < Test::Unit::TestCase

  def test_base
    data = test_data("test_connector")
    conn = ActiveCim::TestConnector.new(data)

    assert_equal([:CSCreationClassName, :CSName, :CreationClassName, :Name], conn.each_key("#{URL}:CIM_FileSystem"){}.to_a)

    assert_nothing_raised do
      conn.each_class_name("#{URL}") do |name|
        conn.each_instance("#{URL}:#{name}") do |instance|
        end
      end
    end
  end
  
end
