require 'shellwords'
require 'json'

class LighthouseRunner
   INTERNAL_ROOT = '/var/lighthouse'

   def initialize output_directory, endpoint_name, url, api_key = nil
      @output_directory = output_directory
      @endpoint_name = endpoint_name
      @url = url
      @api_key = api_key
   end

   def run
      log :info, "Saving results into: '#{absolute_output_path}'"
      docker_run_cmd = <<~DOCKER_RUN
         docker run \
         --rm \
         -v #{absolute_output_path}:/var/lighthouse/:z \
         lighthouse \
         --only-categories=accessibility \
         --chrome-flags='--headless --no-sandbox' \
         --output=json --output=html \
         --output-path="#{internal_output_path}" \
         #{extra_headers} \
         "#{@url}"
      DOCKER_RUN
      log :debug, docker_run_cmd
      cmd docker_run_cmd, {show_out: true, out_level: :info}
   end

   private

   def internal_output_path
      return "#{INTERNAL_ROOT}/#{@endpoint_name}"
   end

   def absolute_output_path
      return File.expand_path(@output_directory)
   end

   def extra_headers
      if @api_key then
        return "--extra-headers=\"{\\\"Authorization\\\": \\\"api #{@api_key}\\\"}\""
      else
        return ""
      end
   end
end
