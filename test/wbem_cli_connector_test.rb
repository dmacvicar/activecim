
require 'test_helper'
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
  
   def setup
     @uri = "http://localhost:5988/root/cimv2"
   end

  # def teardown
  # end

  def test_connector_wbem_cli
    
    conn = ActiveCim::WbemCliConnector.new

    # simulate wbemcli output and return the fixtures
    # mock wbemcli calls, we only want to test how the connector
    # deal with its output
    conn.stubs(:run_wbem_cli).with('gc', '-t', "#{@uri}:Linux_Ext3FileSystem").returns(cli_output_fixture("gc-t-Linux_Ext3FileSystem"))
    conn.stubs(:run_wbem_cli).with('gc', "#{@uri}:Linux_Ext3FileSystem").returns(cli_output_fixture("gc-Linux_Ext3FileSystem"))


        conn.stubs(:run_wbem_cli).with('gc', '-t', "#{@uri}:CIM_FileSystem").returns(cli_output_fixture("gc-t-CIM_FileSystem"))
    conn.stubs(:run_wbem_cli).with('gc', "#{@uri}:CIM_FileSystem").returns(cli_output_fixture("gc-CIM_FileSystem"))
    
    conn.stubs(:run_wbem_cli).with('ecn', @uri).returns(cli_output_fixture("ecn"))
    conn.stubs(:run_wbem_cli).with('ein', "#{@uri}:Linux_Ext3FileSystem").returns(cli_output_fixture("ein-Linux_Ext3FileSystem"))

    conn.stubs(:run_wbem_cli).with('ein', "#{@uri}:CIM_FileSystem").returns(cli_output_fixture("ein-CIM_FileSystem"))

    conn.stubs(:run_wbem_cli).with do |cmd, path|
      cmd == 'gi' and path =~ /Linux_NFS/
    end.returns(cli_output_fixture("gi-CIM_FileSystem-1"))

    # test basic support methods first

    fields = { :SystemCreationClassName => "Linux_ComputerSystem", :SystemName => "tarro", :CreationClassName => "Linux_EthernetPort", :DeviceID => "eth0" }
    fields_s = 'localhost:5988/root/cimv2:Linux_EthernetPort.SystemCreationClassName="Linux_ComputerSystem",SystemName="tarro",CreationClassName="Linux_EthernetPort",DeviceID="eth0"'    
    assert_equal( fields, conn.fields(fields_s))

    fields_s = 'localhost:5988/root/cimv2:Linux_NFS.CSCreationClassName="Linux_ComputerSystem",CSName="some.suse.de",CreationClassName="Linux_NFS",Name="host:/path'
    fields = { :CSCreationClassName => "Linux_ComputerSystem", :CSName => "some.suse.de", :CreationClassName => "Linux_NFS", :Name => "host:/path" }
    assert_equal( fields, conn.fields(fields_s))
    
    # now lets see if the connector parses the output correctly
    
    assert_equal( 70, conn.each_class_name {}.to_a.size, "There are 70 CIM classes")

    instances = []
    conn.each_instance('Linux_Ext3FileSystem') { |i| instances << i }

    #pp instances
    assert_equal(1, instances.size)
    
    assert_equal("/dev/disk/by-id/scsi-SATA_SAMSUNG_HD160JJS0XXJ1DP601084-part2", instances.first[:Name])
    
    # FIXME non-keys are not yet retrieved
    #assert_equal("91", instances.first[:PercentageSpaceUse])
    #assert_equal("ext3", instances.first[:FilesystemType])

    instances = []
    conn.each_instance_path('CIM_FileSystem') do |ins|
      pp conn.instance(ins)
      instances << ins
    end

    assert_equal( 3, instances.size)

    assert_equal( "0A:00:27:00:00:00", instances.first[:PermanentAddress])
  end
  
end
