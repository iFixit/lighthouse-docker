#!/usr/bin/env ruby

require './Runner.rb'
require 'scriptster'
include Scriptster

args = parse_args <<DOCOPT
Lighthouse Runner

Usage:
  #{File.basename __FILE__} <output_directory> <endpoint_name> <URL> [<api_key>]

Options:
  --html              Generate HTML format report
  -h, --help          Show this message.
DOCOPT

log :info, "Running Lighthouse against '#{args["<URL>"]}'"

output_directory = args['<output_directory>']
endpoint_name = args['<endpoint_name>']
url = args['<URL>']
api_key = args['<api_key>']

LighthouseRunner.new(output_directory, endpoint_name, url, api_key).run
