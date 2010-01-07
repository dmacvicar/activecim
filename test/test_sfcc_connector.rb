
$: << File.join(File.dirname(__FILE__), '..', 'ext', 'sfcc')
require 'test_helper'
require 'active_cim/sfcc_connector'
require 'pp'

class SfccConnectorTest < Test::Unit::TestCase
  
   def setup
     @uri = "http://localhost:5988/root/cimv2"
   end

   def test_connector
     conn = ActiveCim::SfccConnector.new
     assert_equal( 70, conn.each_class_name(@uri) {}.to_a.size, "There are 70 CIM classes")

   end
end
