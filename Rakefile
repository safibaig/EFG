#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

begin
  require 'ci/reporter/rake/rspec'
rescue LoadError
  warn 'CI::Reporter not available. Rake Tasks not loaded.'
end

EFG::Application.load_tasks
