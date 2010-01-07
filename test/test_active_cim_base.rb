require File.join(File.dirname(__FILE__), 'test_helper')
require 'active_cim/base'

CIM_URI = "http://localhost:5988/root/cimv2"

class CIM_FileSystem < ActiveCim::Base
  self.site = CIM_URI
end

class TC_ActiveCim_Base < Test::Unit::TestCase
  # def setup
  # end

  # def teardown
  # end

  def test_base
    filesystems = CIM_FileSystem.find(:all)

    assert_equal("#{CIM_URI}:CIM_FileSystem", CIM_FileSystem.object_path)
    #assert_equal([:cs_creation_class_name, :cs_name, :creation_class_name, :name], CIM_FileSystem.keys)
    assert(! filesystems.empty?)
    assert(filesystems.first.available_space > 0)
    assert_kind_of(Fixnum, filesystems.first.available_space)
    
    assert_nothing_raised do
      filesystems.each do |fs|
        fs.file_system_size
      end
    end
    
  end
  
end
