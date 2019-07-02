class LighthouseRunner
   INTERNAL_ROOT = '/var/lighthouse'

   def initialize args
      @output_directory = args['<output_directory>']
      @endpoint_name = args['<endpoint_name>']
      @url = args['<URL>']
      @output_format = (args['--html'] ? 'html' : 'json')
   end

   def run
      log :info, "Saving results into: '#{absolute_output_path}'"
      docker_run_cmd = <<~DOCKER_RUN
         docker run \
         --rm \
         -v #{absolute_output_path}:/var/lighthouse/:z \
         lighthouse \
         --chrome-flags='--headless --no-sandbox' \
         --output #{@output_format} \
         --output-path "#{internal_output_path}" \
         "#{@url}"
      DOCKER_RUN
      log :debug, docker_run_cmd
      cmd docker_run_cmd, {show_out: true, out_level: :info}
   end

   private

   def internal_output_path
      return "#{INTERNAL_ROOT}/#{@endpoint_name}.#{@output_format}"
   end

   def absolute_output_path
      return File.expand_path(@output_directory)
   end
end
