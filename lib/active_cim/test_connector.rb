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
      klass_name = klass_path.split(':')[2]
      doc = YAML::load(File.join(@path, klass_name, "instances.yml"))
      #pp doc

    end
    
  end

end
