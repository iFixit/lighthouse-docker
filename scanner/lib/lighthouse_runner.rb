require 'lib/scan_output'
require 'lib/index'
require_relative '../../lib/utils'
require 'uri'

##
# Sets up runs of Lighthouse on multiple URLs
class LighthouseRunner
  def initialize(config_file_path, output_dir, hostname)
    @config_file_path = config_file_path
    @hostname = hostname
    @output = ScanOutput.new(output_dir, hostname)
    @index = Index.new
  end

  def run
    log :info, 'Running Lighthouse scan'
    frameworks(@config_file_path, @hostname).each do |framework|
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

  def frameworks(config_file_path, hostname = nil)
    config_contents = JSON.load(config_file_path)
    log :debug, "Read config file: '#{config_file_path}'"
    config_contents.map do |framework, pages|
      Framework.new framework, pages, hostname
    end
  end
end

Page = Struct.new :name, :url

class Framework
  attr_reader :name

  def initialize(name, pages, hostname)
    @name = name
    @pages = pages
    @hostname = hostname
  end

  def pages
    @pages.map do |name, url|
      uri = URI.parse url
      uri.host = @hostname if @hostname
      Page.new name, uri
    end
  end
end
