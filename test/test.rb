
$: << File.join(File.dirname(__FILE__), "..", "ext", "sfcc")
$: << File.join(File.dirname(__FILE__), "..", "lib")

require 'sfcc'
require 'active_cim/base'

class CIM_RunningOS < ActiveCim::Base
  self.cim_class_name = :CIM_RunningOS
end

b = CIM_RunningOS.new
b.cim_class_name

client = Sfcc::Client.new('http', 'localhost', '5988', 'root', 'novell' );

puts client.inspect

client.each_class_name do |cn|
  puts cn
end

