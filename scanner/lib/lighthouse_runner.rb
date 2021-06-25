require 'lib/scan_output'
require 'lib/config_reader'
require 'lib/index'

##
# Sets up runs of Lighthouse on multiple URLs
class LighthouseRunner
   def initialize(config_file_path, output_dir, hostname)
      @output = ScanOutput.new(output_dir, hostname)
      @config_reader = ConfigReader.new(config_file_path, hostname)
      @index = Index.new
   end

   def run
      log :info, "Running Lighthouse scan"
      @config_reader.frameworks.each do |framework|
         framework_dir = @output.get_framework_dir(framework.name)
         framework.pages.each do |page|
            @index.add framework.name, page.name
            run_scan framework_dir, page.name, page.url
         end
      end
      @index.generate_index @output.scan_dir
   end

   def run_scan(framework_dir, endpoint_name, target_url)
     Dir.chdir '/opt/lighthouse-docker' do
       args = ['./run.rb', '--html', framework_dir.to_path, endpoint_name, target_url.to_s]
       log(:info, args.join(' '))
       # Try running lighthouse up to three times. This avoids having to start
       # all the way over for little glitches
       success=false
       5.times do |i|
         success = system(*args)
         if success
           break
         else
           log :info, "Retrying; run #{i+1} failed on ${target_url.to_s}"
           # Delay before trying again
           sleep 10
         end
       end
       success or exit(70) # BSD's EX_SOFTWARE exit code
     end
   end
end
