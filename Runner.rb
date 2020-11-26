class LighthouseRunner
   INTERNAL_ROOT = '/var/lighthouse'

   def initialize output_format, output_format_options, output_directory, endpoint_name, url, session_token = nil
      @output_format = output_format
      @output_format_options = output_format_options
      @output_directory = output_directory
      @endpoint_name = endpoint_name
      @url = url
      @session_token = session_token
   end

   def run
      log :info, "Saving results into: '#{absolute_output_path}'"
      docker_run_cmd = <<~DOCKER_RUN
         docker run \
         --rm \
         -v #{absolute_output_path}:/var/lighthouse/:z \
         lighthouse \
         --chrome-flags='--headless --no-sandbox' \
         #{@output_format_options} \
         --output-path "#{internal_output_path}" \
         #{extra_headers} \
         "#{@url}"
      DOCKER_RUN
      log :debug, docker_run_cmd
      cmd docker_run_cmd, {show_out: true, out_level: :info}
   end

   private

   def internal_output_path
      return "#{INTERNAL_ROOT}/#{@endpoint_name}#{@output_format}"
   end

   def absolute_output_path
      return File.expand_path(@output_directory)
   end

   def extra_headers
      if @session_token then
         return %Q[--extra-headers='{"Cookie": "session_4813=#{@session_token}"}']
      else
         return ""
      end
   end
end
