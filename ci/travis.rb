#!/usr/bin/env ruby

require 'fileutils'
include FileUtils

success = system "export DISPLAY=:99.0 && bundle exec rake $TEST"

exit(success)
