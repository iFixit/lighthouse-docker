require 'date'
require 'open-uri'
require 'json'
require 'scriptster'

require_relative 'config'

class ScanOutput
   attr_reader :scan_dir

   def initialize output_dir, hostname
      @output_dir = output_dir
      scan_time = DateTime.now.strftime("%Y%m%d-%H%M%S")
      @scan_name = Dir.chdir(File.dirname(__FILE__)) do
         deploy_url = generate_deploy_url(hostname)
         Scriptster.log :debug, "Fetching deployment information from '#{deploy_url}'"
         current_hash = URI.open(deploy_url) do |fi|
            blob = JSON.load(fi)
            blob['id']
         end
         current_branch =
            `git name-rev --name-only #{current_hash}`.strip.gsub(%r{/}, '-')
         branchname = current_branch == '' ? 'missing' : current_branch
         "#{hostname}-#{scan_time}-#{current_hash}-#{branchname}"
      end
      Scriptster.log :debug, "Using name for scan: #{@scan_name}"
      @scan_dir = @output_dir / @scan_name
   end

   def get_framework_dir framework
      framework_subdir = @scan_dir / framework
      Scriptster.log :debug, "Creating framework dir #{framework_subdir}"
      framework_subdir.mkpath
      return framework_subdir
   end

   private
   def make_output_dir
      Scriptster.log :debug, "Creating output directory..."
      @scan_dir.mkpath
   end
end
