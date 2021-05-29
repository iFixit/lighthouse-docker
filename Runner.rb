class LighthouseRunner
   INTERNAL_ROOT = '/var/lighthouse'

   def initialize output_format, output_format_options, output_directory, endpoint_name, url
      @output_format = output_format
      @output_format_options = output_format_options
      @output_directory = output_directory
      @endpoint_name = endpoint_name
      @url = url
   end

   def run
      log :info, "Saving results into: '#{absolute_output_path}'"
      config_path = File.join(__dir__, "lighthouse-config.js")
      internal_config_path = '/var/lighthouse-config.js'
      args = [
        'docker', 'run',
        '--rm',
        '-v', "#{absolute_output_path}:/var/lighthouse/:z",
        '-v', "#{config_path}:#{internal_config_path}",
        'lighthouse',
        "--chrome-flags='--headless --no-sandbox'",
        "--only-categories=accessibility,best-practices,performance,seo",
        '--config-path', internal_config_path,
        *@output_format_options,
        '--output-path', internal_output_path,
        @url
      ]
      log(:info, args.join(' '))
      system(*args) or exit(70) # BSD's EX_SOFTWARE exit code
   end

   private

   def internal_output_path
      return "#{INTERNAL_ROOT}/#{@endpoint_name}#{@output_format}"
   end

   def absolute_output_path
      return File.expand_path(@output_directory)
   end
end
