require 'active_cim/test/macros/connector'

module ActiveCim
  module Test
    module Macros
      
      def self.included(base)
        base.extend ConnectorMacrosClassMethods
      end
      
    end
  end
end
