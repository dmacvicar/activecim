#/usr/bin/env ruby
require 'rubygems'
require 'pp'

$: << File.join(File.dirname(__FILE__), "..", "lib")
require 'active_cim/base'

CIM_URI = "http://localhost:5988/root/cimv2"

class CIM_FileSystem < ActiveCim::Base
  self.site = CIM_URI
end

fss = CIM_FileSystem.find(:all)

pp CIM_FileSystem.object_path
pp CIM_FileSystem.keys

fss.each do |fs|
  pp fs.object_path
  fs.available_space
  fs.file_system_size
end

class FileSystem < ActiveCim::Base
  self.site = CIM_URI
  self.cim_class_name = 'CIM_FileSystem'
end

fss = FileSystem.find(:all)
fss.each do |fs|
  pp fs.object_path
  puts fs.to_xml
end


