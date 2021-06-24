require 'json'
require 'logger'
require 'uri'

require_relative 'scan_output'
require_relative 'utils'

##
# Sets up runs of Lighthouse on multiple URLs
class LighthouseRunner
  Log = Logger.new($stderr, 'LighthouseRunner')
  def initialize(config_file_path, output_dir, hostname)
    @config_file_path = config_file_path
    @hostname = hostname
    @output = ScanOutput.new(output_dir, hostname)
  end

  def run
    Log.info('Running Lighthouse scan')
    pages = pages_from_config(@config_file_path)
    pages.each do |page|
      run_scan page
    end
    generate_index pages
  end

  def run_scan(page)
    framework_dir = @output.get_framework_dir(page.framework_name)
    exit(70) unless Lighthouse.run(
      framework_dir.realpath.to_path,
      page.name,
      page.url.to_s,
      '--output', 'html'
    )
  end

  def pages_from_config(config_file_path)
    config_contents = JSON.load(config_file_path)
    Log.debug("Read config file: '#{config_file_path}'")

    config_contents.flat_map do |framework, pages|
      pages.map do |name, url|
        Page.new framework, name, get_uri(url)
      end
    end
  end

  def get_uri(url)
    uri = URI.parse url
    uri.host = @hostname if @hostname
    uri
  end

  def generate_index(pages)
    framework_groups = pages.group_by(&:framework_name)
    index = framework_groups.transform_values { |group| group.map(&:name) }

    write_index index
  end

  def write_index(index)
    Log.info('Generating index file')
    File.write(@output.scan_dir / 'index.json', JSON.dump(index))
  end
end

Page = Struct.new :framework_name, :name, :url
