$: << File.join(File.dirname(__FILE__), "test")
require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'

#require 'rake/gempackagetask'
#require 'rake/rdoctask'
#require 'rake/testtask'

task :default => :test

HOE = Hoe.spec 'active_cim' do
  developer('Duncan Mac-Vicar P.', 'dmacvicar@suse.de')
  developer('Klaus Kaempf', 'kkaempf@suse.de')
  self.summary = "ActiveRecord like API for CIM access"
  self.description = "ActiveCim is a rails-way of accessing CIM data in a CIMOM/client independent way. Currently it supports access using wbemcli and SBLIM client library"
  self.readme_file = ['README', ENV['HLANG'], 'rdoc'].compact.join('.')
  self.history_file = ['CHANGELOG', ENV['HLANG'], 'rdoc'].compact.join('.')
  self.extra_rdoc_files = FileList['*.rdoc']
  #self.clean_globs = [
  #  'lib/sfcc/*.{o,so,bundle,a,log,dll}',
  #  'lib/sfcc/sfcc.rb',
  #]
end

