require File.join(File.dirname(__FILE__), 'test_helper')
require 'active_cim/connector'
require 'active_cim/wbem_cli_connector'
require 'pp'

# helper to find the fixture
def cli_output_fixture(name)
  File.open(test_data(File.join('wbem_cli_connector', "#{name}.txt"))).read
end

# This test uses fixtures that simulate wbemcli output
#
# ecn.txt
# ein-Linux_EthernetPort.txt
# ein-Linux_Ext3FileSystem.txt
# ein-Linux_NonExistantClass.txt
# gi-Linux_Ext3FileSystem-1.txt
#
class TC_WbemCliConnectorTest < Test::Unit::TestCase

  context "a faked wbemcli command" do    
    setup do
      @path = ActiveCim::Cim::ObjectPath.parse("http://localhost:5988/root/cimv2")
      @conn = ActiveCim::Connector.create(:wbem_cli)
    end

    should "have classes including Linux_OperatingSystem" do
      assert(@conn.each_class_name(@path).to_a.include?(@path.and_class(:Linux_OperatingSystem)))
    end
    
    should "have instances of CIM_FileSystem" do
      instances = @conn.each_instance_name(@path.and_class(:CIM_FileSystem)).to_a
      assert ! instances.select { |x| x.class_name == :Linux_Ext3FileSystem }.empty?
    end

    should "call a method correctly" do
      argsout = {}
      @conn.invoke_method(@path.and_class(:Linux_OperatingSystem).with(:CSCreationClassName => "Linux_ComputerSystem", :CSName => "tarro", :CreationClassName => "Linux_OperatingSystem", :Name => "tarro"), :execCmd, {:cmd => "cat /etc/SuSE-release"}, argsout)
    end

    should "get types correctly" do
      pp @conn.connector.property_types(@path.and_class(:Linux_OperatingSystem))
      pp @conn.connector.method_types(@path.and_class(:Linux_OperatingSystem))
      pp @conn.connector.parameter_types(@path.and_class(:Linux_OperatingSystem))
    end
    
  end
end
