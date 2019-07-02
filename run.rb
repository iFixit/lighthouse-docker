#!/usr/bin/env ruby

require './Runner.rb'
require 'scriptster'
include Scriptster

args = parse_args <<DOCOPT
Lighthouse Runner

Usage:
  #{File.basename __FILE__} [--html] <output_directory> <endpoint_name> <URL>

Options:
  --html              Generate HTML format report
  -h, --help          Show this message.
DOCOPT

log :info, "Running Lighthouse against '#{args["<URL>"]}'"

runner = LighthouseRunner.new(args).run
