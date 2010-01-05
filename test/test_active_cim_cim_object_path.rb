require File.join(File.dirname(__FILE__), 'test_helper')
require 'active_cim/cim/object_path'

class ActiveCimCimObjectPathTest < Test::Unit::TestCase

  context "the ObjectPath class" do

    should "parse a namespace path" do
      op = ActiveCim::Cim::ObjectPath.parse('http://localhost:5988/root/cimv2')
      assert_equal "http", op.scheme
      assert_equal "localhost", op.host
      assert_equal 5988, op.port
      assert_equal "root/cimv2", op.namespace
      assert_equal '', op.object_name
      assert ! op.class?
      assert ! op.instance?
      assert_equal({}, op.keys)
      assert_equal 'http://localhost:5988/root/cimv2:Linux_ComputerSystem', op.and_class('Linux_ComputerSystem').to_s
      assert_equal 'http://localhost:5988/root/cimv2:Linux_ComputerSystem.CreationClassName="Linux_ComputerSystem",Name="some.suse.de"', op.and_class('Linux_ComputerSystem').with(:CreationClassName => 'Linux_ComputerSystem', :Name => 'some.suse.de').to_s
    end
    
    should "parse an class object path" do
      op = ActiveCim::Cim::ObjectPath.parse('http://localhost:5988/root/cimv2:Linux_ComputerSystem')
      assert_equal "http", op.scheme
      assert_equal "localhost", op.host
      assert_equal 5988, op.port
      assert_equal "root/cimv2", op.namespace
      assert_equal 'Linux_ComputerSystem', op.object_name
      assert op.class?
      assert ! op.instance?
      assert_equal({}, op.keys)
      assert_equal 'http://localhost:5988/root/cimv2:Linux_ComputerSystem', op.to_s
    end
    
    should "parse an instance object path" do
      op = ActiveCim::Cim::ObjectPath.parse('http://localhost:5988/root/cimv2:Linux_ComputerSystem.CreationClassName="Linux_ComputerSystem",Name="some.suse.de"')
      assert_equal "http", op.scheme
      assert_equal "localhost", op.host
      assert_equal 5988, op.port
      assert_equal 'Linux_ComputerSystem.CreationClassName="Linux_ComputerSystem",Name="some.suse.de"', op.object_name
      assert_equal "root/cimv2", op.namespace
      assert ! op.class?
      assert op.instance?
      keys =  {:CreationClassName => 'Linux_ComputerSystem', :Name => 'some.suse.de'}
      assert_equal keys, op.keys
      assert_equal 'http://localhost:5988/root/cimv2:Linux_ComputerSystem.CreationClassName="Linux_ComputerSystem",Name="some.suse.de"', op.to_s
    end
  end
end
