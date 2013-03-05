#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__))
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require "test_app"

App.run(ARGV)
