require File.join(File.dirname(__FILE__), 'test_helper')
require 'active_cim/connector_adapter'
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

  context "for every connector" do
    [:wbem_cli, :sfcc].each do |connector|
      context "for connector #{connector}" do    
        setup do
          @path = ActiveCim::Cim::ObjectPath.parse("http://localhost:5988/root/cimv2")
          @conn = ActiveCim::ConnectorAdapter.create(connector)
        end

        should "#{connector}: have classes including Linux_OperatingSystem" do
          assert(@conn.class_names(@path).include?(@path.and_class(:Linux_OperatingSystem)))
        end
    
        should "#{connector}: have instances of CIM_FileSystem" do
          instances = @conn.instance_names(@path.and_class(:CIM_FileSystem))
          assert ! instances.select { |x| x.class_name == :Linux_Ext3FileSystem }.empty?
        end

        should "#{connector}: call a method correctly" do
          argsout = {}
          ret = @conn.invoke_method(@path.and_class(:Linux_OperatingSystem).with(:CSCreationClassName => "Linux_ComputerSystem", :CSName => "tarro", :CreationClassName => "Linux_OperatingSystem", :Name => "tarro"), :execCmd, {:cmd => "cat /etc/SuSE-release"}, argsout)
          assert argsout.has_key?(:out)          
          assert(argsout[:out] =~ /VERSION/)
          assert_equal(0, ret)
        end

        #should "get types correctly" do
        #pp @conn.connector.class_properties(@path.and_class(:Linux_OperatingSystem))
        #pp @conn.connector.class_methods(@path.and_class(:Linux_OperatingSystem))
        #pp @conn.connector.property_types(@path.and_class(:Linux_OperatingSystem))
        #pp @conn.connector.method_types(@path.and_class(:Linux_OperatingSystem))
        #pp @conn.connector.parameter_types(@path.and_class(:Linux_OperatingSystem))
        #end
    
      end
    end

  end
end
