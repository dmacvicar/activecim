
require 'rubygems'
require 'ffi'

module Sblim
  module Lib
    extend FFI::Library

    class CIMClient < FFI::Struct
    #  layout :hdl, :pointer,
    #         :ft, :pointer
    #  end
    end
    
    class CIMEnv < FFI::Struct
    end
    
    #
    # find Tokyo Tyrant lib

    paths = [ "/usr/lib/libcimcclient.so", "/usr/lib64/libcimcclient.so" ]

    begin
 
      ffi_lib(*paths)
 
    rescue LoadError => le
      raise("didn't find sblim libs on your system. ")
    end

    attach_function :NewCIMCEnv, [ :string, :int, :pointer, :pointer ], :pointer
  end
end

rc = FFI::MemoryPointer.new :pointer
msg = FFI::MemoryPointer.new :pointer

env = Sblim::Lib.NewCIMCEnv("XML2", 0, rc, msg)
puts env.class
puts rc.read_int
puts msg.read_string
