# -*- ruby -*-

require 'rubygems'
require 'hoe'
require 'spec/rake/spectask'
require './lib/restful_captcha.rb'

Hoe.new('RestfulCaptcha', RestfulCaptcha::VERSION) do |p|
  # p.rubyforge_name = 'RestfulCaptchax' # if different than lowercase project name
  p.developer('Jesse Hallett', 'jesse@copiousinc.com')
end

# vim: syntax=Ruby

desc "Run all specs in the spec directory"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
end

desc "Run all specs in the spec directory with RCov"
Spec::Rake::SpecTask.new('spec:rcov') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'examples']
end
