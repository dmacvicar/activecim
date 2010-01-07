
require 'test_helper'
require 'active_cim/test_connector'
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

    CIM_FileSystem::connector = ActiveCim::TestConnector.new(test_data("test_connector"))
    
    fss = CIM_FileSystem.find(:all)

    assert_equal("#{CIM_URI}:CIM_FileSystem", CIM_FileSystem.object_path)
    assert_equal([:cs_creation_class_name, :cs_name, :creation_class_name, :name], CIM_FileSystem.keys)
    assert_equal(3, fss.size)
    assert_equal("74355306496", fss.first.available_space)
    
    assert_nothing_raised do
      fss.each do |fs|
        fs.file_system_size
      end
    end
    
  end
  
end
