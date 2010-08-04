# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require "active_cim"

Gem::Specification.new do |s|
  s.name        = "active_cim"
  s.version     = ActiveCim::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Duncan Mac-Vicar"]
  s.email       = ["dmacvicar@suse.de"]
  s.homepage    = "http://www.github.com/dmacvicar/activecim"
  s.summary = "ActiveRecord like API for CIM access"
  s.description = "ActiveCim is a rails-way of accessing CIM data in a CIMOM/client independent way. Currently it supports access using wbemcli and SBLIM client library"
  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency("sfcc", [">= 0.1.1"])
  s.add_dependency("nokogiri", [">= 1.4"])
  s.add_dependency("activesupport", [">= 2.3"])

  s.add_development_dependency("bundler", [">= 1.0.rc.2"])
  s.add_development_dependency("mocha", [">= 0.9"])
  s.add_development_dependency("yard", [">= 0.5"])
  s.add_development_dependency("shoulda", [">= 0"])

  s.files        = Dir.glob("lib/**/*") + %w(CHANGELOG.rdoc README.rdoc)
  s.require_path = 'lib'
  s.post_install_message = <<-POST_INSTALL_MESSAGE
  ____
/@    ~-.
\/ __ .- | remember to have fun! 
 // //  @  

  POST_INSTALL_MESSAGE
end
