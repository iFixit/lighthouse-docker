require 'lib/framework'

class ConfigReader
  def frameworks(config_file_path, hostname = nil)
    config_contents = JSON.load(config_file_path)
    log :debug, "Read config file: '#{config_file_path}'"
    config_contents.map do |framework, pages|
      Framework.new framework, pages, hostname
    end
  end
end
