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
      docker_run_cmd = <<~DOCKER_RUN
         docker run \
         --rm \
         -v #{absolute_output_path}:/var/lighthouse/:z \
         lighthouse \
         --only-categories=accessibility \
         --chrome-flags='--headless --no-sandbox' \
         --output=json --output=html \
         --output-path "#{internal_output_path}" \
         "#{@url}"
      DOCKER_RUN
      log :debug, docker_run_cmd
      cmd docker_run_cmd, {show_out: true, out_level: :info}
   end

   private

   def internal_output_path
      return "#{INTERNAL_ROOT}/#{@endpoint_name.gsub(/\//, '%2F')}#{@output_format}"
   end

   def absolute_output_path
      return File.expand_path(@output_directory)
   end
end
