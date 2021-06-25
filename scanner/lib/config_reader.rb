require 'lib/framework'

class ConfigReader
   def initialize config_file_path, hostname=nil
      @config_contents = JSON.load(config_file_path)
      @hostname = hostname
      log :debug, "Read config file: '#{config_file_path}'"
   end

   def frameworks
      return @config_contents.map do |framework, pages|
         Framework.new framework, pages, @hostname
      end
   end
end
