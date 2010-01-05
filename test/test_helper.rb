require 'test/unit'
require 'rubygems'
require 'mocha'
require 'shoulda'

$: << File.join(File.dirname(__FILE__), "..", "lib")

def test_data(name)
  File.join(File.dirname(__FILE__), "data", name)
end
