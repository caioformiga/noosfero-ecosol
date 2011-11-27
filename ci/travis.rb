#!/usr/bin/env ruby

require 'fileutils'
include FileUtils

commands = [
  "cp config/database.yml.travis config/database.yml",
  "psql -c 'create database myapp_test;' -U postgres",
  "mkdir -p tmp/pids log",
]
commands.each do |command|
  system "#{command} > /dev/null 2>&1"
end

success = system 'RAILS_ENV=test bundle exec rake test'

exit(success)
