#!/usr/bin/env ruby

require 'pathname'

require 'docopt'

require_relative 'lib/lighthouse_runner'

begin
args = Docopt.docopt <<~DOCOPT
  Run an automated Lighthouse scan. Emit results into a target directory.

  Usage:
    #{File.basename __FILE__} [--hostname=<hostname>] <config_file> <output_dir> [-h]

  Options:
    -h, --help             Show this message.
    --hostname=<hostname>  Replace the hostname specified in the config file [default: www.ifixit.com]
                           with the provided hostname
DOCOPT
rescue Docopt::Exit => e
  puts e.message
  exit
end

config_file_path = Pathname.new args['<config_file>']
output_dir = Pathname.new args['<output_dir>']
hostname = args['--hostname']

LighthouseRunner.new(config_file_path, output_dir, hostname).run
