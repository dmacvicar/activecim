require File.join(File.dirname(__FILE__), 'test_helper')
require 'active_cim/connector_adapter'
require 'active_cim/wbem_cli_connector'
require 'pp'

# helper to find the fixture
def cli_output_fixture(name)
  File.open(test_data(File.join('wbem_cli_connector', "#{name}.txt"))).read
end

class TC_WbemCliConnectorTest < Test::Unit::TestCase

  context "connector" do
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

        should "#{connector}: return properties" do
          @conn.instance_names(@path.and_class(:CIM_FileSystem)).each do |instance|
            properties = @conn.instance_properties(instance)
            assert properties[:FileSystemSize] > 0
            assert_kind_of Fixnum, properties[:FileSystemSize]
            assert_kind_of String, properties[:Name]
          end
        end
        
        should "#{connector}: call a method correctly" do
          argsout = {}
          ret = @conn.invoke_method(@path.and_class(:Linux_OperatingSystem).with(:CSCreationClassName => "Linux_ComputerSystem", :CSName => "tarro", :CreationClassName => "Linux_OperatingSystem", :Name => "tarro"), :execCmd, {:cmd => "cat /etc/SuSE-release"}, argsout)
          assert argsout.has_key?(:out)          
          assert(argsout[:out] =~ /VERSION/)
          assert_equal(0, ret)
        end
    
      end
    end

  end
end
