#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

begin
  require 'ci/reporter/rake/rspec'
  # ci_reporter gem outputs data to spec/reports by default
  # deleting that directory beforehand
  # but this app uses spec/reports for actual specs
  # so use a different directory
  ENV["CI_REPORTS"] = 'spec/ci_reports'
rescue LoadError
  # warn 'CI::Reporter not available. Rake Tasks not loaded.'
end

EFG::Application.load_tasks

Rake::Task[:default].clear
task :default => [:"parallel:prepare", :"parallel:spec"]
