Dir['**/*_test.rb'].each { |test_case| require test_case }
Dir['**/test_*.rb'].each { |test_case| require test_case }
