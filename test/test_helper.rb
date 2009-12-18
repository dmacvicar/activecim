require 'test/unit'
require 'mocha'

$: << File.join(File.dirname(__FILE__), "..", "lib")

def test_data(name)
  File.join(File.dirname(__FILE__), "data", name)
end
