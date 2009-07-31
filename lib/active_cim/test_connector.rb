require 'yaml'
require 'pp'

module ActiveCim

  # Connector that retrieves static data from a directory specified
  # in site
  #
  #
  class TestConnector

    # path to the data
    def initialize(path)
      @path = path
    end

    def each_class_name(path)
      Dir.glob(File.join(@path, "*")).each do |dir|
        yield File.basename(dir) if File.directory?(dir)
      end
    end

    def each_instance(klass_path)
      klass_name = klass_path.split(':')[3]
      doc = YAML::load_file(File.join(@path, klass_name, "instances.yml"))
      doc.each do |k,v|
        yield k
      end
    end

    def instance(path)
      klass_name = "CIM_FileSystem"
      doc = YAML::load_file(File.join(@path, klass_name, "instances.yml"))
      return doc[path] if doc.has_key?(path)
      raise "Instance not found"
    end
  end
end
