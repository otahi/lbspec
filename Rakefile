#!/usr/bin/env rake
# -*- coding: utf-8 -*-

require 'rake'
require 'highline/import'

task :default => :travis
task :travis => [:spec, :rubocop, 'coveralls:push']

require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'coveralls/rake/task'

Coveralls::RakeTask.new

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = %w(lib/**/*.rb spec/**/*.rb)
end

task :release do |t|
  puts "Releaseing gem"
  require_relative 'lib/lbspec'
  version_current = Lbspec::VERSION
  puts "now v#{version_current}"
  version_new = ask("Input version")

  file_path = 'lib/lbspec/version.rb'
  text = File.read(file_path)
  text = text.gsub(/#{version_current}/, version_new)
  File.open(file_path, "w") {|file| file.puts text}

  sh('gem build lbspec.gemspec')
  if agree("Shall we continue? ( yes or no )")
    puts "Pushing gem..."
    sh("gem push lbspec-#{version_new}.gem")
  else
    puts "Exiting"
  end
end
