require 'uri'
require 'open3'
require 'active_cim/connector'

module ActiveCim
   
    class WbemCliConnector < Connector

    def initialize(site)
      super(site)
    end
    
    def run_wbem_cli(args)
      cmd = "wbemcli #{args}"
      stdin, stdout, stderr = Open3::popen3(cmd)
      # wbemcli does not exit with non zero so
      # raise if the exception message is shown
      err = stderr.readlines
      # something bad happened?
      if not err.empty?
        err.reject! { |x| x == "*\n" }
        msg = err.map { |x| x =~ /^\* (.*)/; $1 }.join("\n")
        if msg =~ /CIM_ERR_INVALID_CLASS/
          raise CimClassNotFound
        else
          raise msg + " (when executing #{cmd})" 
        end
      end
       stdout.readlines
    end
      
    def each_class_name
      ENV['WBEMCLI_IND'] = ": #{site}"
      out = run_wbem_cli "ecn '#{site}'"
      out.each do |line|
        yield line.split(':').last.chomp
      end
    end

    # iterates over each path describing an instance
    def each_instance_path(klass_name)      
      out = run_wbem_cli "ein '#{site}:#{klass_name}'"
      out.each do |line|
        yield line.split(':').last.chomp
      end
    end
    
    # iterates over each instance giving
    # on each iteration the fields needed to
    # identify the instance
    def each_instance(klass_name)
      each_instance_path(klass_name) do |path|
        yield fields(path)
      end
    end
    
    # get instance given a encoded path
    # the instance is defin
    def instance(path)      
      out = run_wbem_cli "gi '#{site}:#{path}'"      
      fields(path)
    end

    private

    # takes encoded properties and returns
    # a map of properties
    def fields(path)
      fields = Hash.new
      
      nothing, rest = path.split(':')
      pairs = path[path.index("."), path.size].chomp.split(',')
      pairs.each do |pair|
        puts pair
        key, value = pair.split('=')
        value = value.gsub(/"/, "") if not value.nil?
        fields[key.to_sym] = value
      end
      fields
    end
      
  end
  
end
