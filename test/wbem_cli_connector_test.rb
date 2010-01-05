require File.join(File.dirname(__FILE__), 'test_helper')
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
      @conn = ActiveCim::WbemCliConnector.new

      # simulate wbemcli output and return the fixtures
      # mock wbemcli calls, we only want to test how the connector
      # deal with its output
      @conn.stubs(:run_wbem_cli).with('gc', '-t', "#{@uri}:CIM_FileSystem").returns(cli_output_fixture("gc-t-CIM_FileSystem"))
      @conn.stubs(:run_wbem_cli).with('gc', "#{@uri}:CIM_FileSystem").returns(cli_output_fixture("gc-CIM_FileSystem"))
      @conn.stubs(:run_wbem_cli).with('ein', "#{@uri}:CIM_FileSystem").returns(cli_output_fixture("ein-CIM_FileSystem"))
      @conn.stubs(:run_wbem_cli).with do |cmd, opt, path|
        cmd == "gi"
      end.returns(cli_output_fixture("gi-CIM_FileSystem-1"))

      # Fake Linux_OperatingSystem
      @conn.stubs(:run_wbem_cli).with('ein', "#{@uri}:Linux_OperatingSystem").returns(cli_output_fixture("ein-Linux_OperatingSystem"))
     
      # all classes
      @conn.stubs(:run_wbem_cli).with('ecn', @uri).returns(cli_output_fixture("ecn"))  
    end

    should "have 70 classes" do
      assert_equal( 70, @conn.each_class_name(@uri) {}.to_a.size, "There are 70 CIM classes")
    end

    should "have 3 instances of CIM_FileSystem" do
      instances = []
      @conn.each_instance(path.and_class(CIM_FileSystem)) do |i|
        instances << @conn.instance(i)
      end
      assert_equal(3, instances.size)    
      assert_equal("host2:/homedir/dearuser", instances.first[:Name])    
      # ensure all propertes are there
      assert_equal( 58, instances.first.size)
    end
  end
end
