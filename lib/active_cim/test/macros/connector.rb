require 'active_cim/cim/object_path'

module ActiveCim
  module Test
    module Macros
      
      module ConnectorMacrosClassMethods
      # Describes how a connector should behave
      def should_behave_like_a_connector(options={})

        options[:root] ||= ActiveCim::Cim::ObjectPath.parse("http://localhost:5988/root/cimv2")
        path = options[:root]
        
        should "have classes including Linux_OperatingSystem" do
          assert(@connector.class_names(path).include?(path.and_class(:Linux_OperatingSystem)))
        end
    
        should "have instances of CIM_Process" do
          instances = @connector.instance_names(path.and_class(:CIM_Processor))
          assert ! instances.select { |x| x.class_name == :Linux_Processor }.empty?
        end

        should "return properties" do
          @connector.instance_names(path.and_class(:CIM_Processor)).each do |instance|
            assert_kind_of ActiveCim::Cim::ObjectPath, instance
            properties = @connector.instance_properties(instance)
            assert properties[:MaxClockSpeed] >= 0
            assert_kind_of Fixnum, properties[:MaxClockSpeed]
            assert_kind_of String, properties[:Name]
            # try creation date
          end
        end
        
        should "call a method correctly" do
          argsout = {}
          first_os = @connector.instance_names(path.and_class(:CIM_OperatingSystem)).first
          ret = @connector.invoke_method(first_os, :execCmd, {:cmd => "cat /etc/SuSE-release"}, argsout)
          assert argsout.has_key?(:out)          
          assert(argsout[:out] =~ /VERSION/)
          assert_equal(0, ret)
        end

        should "return association names" do
          first_computer = @connector.instance_names(path.and_class(:CIM_ComputerSystem)).first
          assert_not_nil first_computer
          assoc = @connector.association_names(first_computer, :CIM_RunningOS)
          assert !assoc.to_a.empty?
          assoc.each do |assoc|
            assert_kind_of ActiveCim::Cim::ObjectPath, assoc
            assert_match(/(.+)_OperatingSystem/, assoc.class_name.to_s)
          end
        end
        
      end
      end
    
    end
  end
end
