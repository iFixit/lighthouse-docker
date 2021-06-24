require 'lib/scan_output'
require 'lib/config_reader'
require 'lib/index'
require_relative '../../lib/utils'

##
# Sets up runs of Lighthouse on multiple URLs
class LighthouseRunner
  def initialize(config_file_path, output_dir, hostname)
    @output = ScanOutput.new(output_dir, hostname)
    @config_reader = ConfigReader.new(config_file_path, hostname)
    @index = Index.new
  end

  def run
    log :info, 'Running Lighthouse scan'
    frameworks.each do |framework|
      framework_dir = @output.get_framework_dir(framework.name)
      framework.pages.each do |page|
        @index.add framework.name, page.name
        run_scan framework_dir, page.name, page.url
      end
    end
    @index.generate_index @output.scan_dir
  end

  def run_scan(framework_dir, endpoint_name, target_url)
    exit(70) unless Lighthouse.run(
      framework_dir.to_path,
      endpoint_name,
      target_url.to_s,
      '--output', 'html'
    )
  end

  def frameworks
    @config_reader.frameworks
  end
end
