require 'lib/index'
require 'lib/scan_output'
require 'uri'
require_relative '../../lib/utils'

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
    pages(@config_file_path, @hostname) do |page|
      @index.add page.framework_name, page.name
      run_scan page
    end
    @index.generate_index @output.scan_dir
  end

  def run_scan(page)
    framework_dir = @output.get_framework_dir(page.framework_name)
    exit(70) unless Lighthouse.run(
      framework_dir.to_path,
      page.name,
      page.url.to_s,
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

  def pages(config_file_path, hostname = null)
    pages = frameworks(config_file_path, hostname).flat_map do |framework|
      framework.pages
    end
    pages.each do |page|
      yield page
    end
  end
end

Page = Struct.new :framework_name, :name, :url

##
# Represents the lighthouse runs for a particular framework
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
      Page.new @name, name, uri
    end
  end
end
