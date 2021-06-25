#!/usr/bin/env ruby
$LOAD_PATH.unshift File.dirname(__FILE__)

require 'pathname'
require 'json'

require 'scriptster'
include Scriptster

require 'fileutils'
include FileUtils

require 'lib/lighthouse_runner'

args = parse_args <<~DOCOPT
  Run an automated Lighthouse scan. Emit results into a target directory.

  Usage:
    #{File.basename __FILE__} [--hostname=<hostname>] <config_file> <output_dir> [-h]

  Options:
    -h, --help             Show this message.
    --hostname=<hostname>  Replace the hostname specified in the config file [default: www.ifixit.com]
                           with the provided hostname
DOCOPT

config_file_path = Pathname.new args['<config_file>']
output_dir = Pathname.new args['<output_dir>']
hostname = args['--hostname']

LighthouseRunner.new(config_file_path, output_dir, hostname).run
