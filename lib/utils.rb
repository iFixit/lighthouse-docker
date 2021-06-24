require 'English'
require 'logger'
require 'pathname'
require 'timeout'

module Lighthouse
  Log = Logger.new($stderr, progname: 'Lighthouse')
  InternalPath = Pathname('/var/lighthouse/')

  def self.run(
    bind_path,
    target,
    *args,
    chrome_flags: '--headless --no-sandbox'
  )
    5.times do
      # Exit the `lighthouse` function if the command succeeds
      return true if run_once(
        bind_path,
        target,
        *args,
        "--chrome-flags=#{chrome_flags}"
      )

      Log.error "Error running command. Exit status was #{$CHILD_STATUS}."
    end
    false
  end

  def self.run_once(
    bind_path,
    target,
    *args
  )
    docker_args = [
      'docker', 'run',
      '--rm',
      '-v', "#{bind_path}:#{InternalPath}:z",
      'lighthouse',
      '--output-path', (InternalPath / target).to_path,
      *args
    ]
    Log.info docker_args.join(' ')
    ExecHelpers.limited_system(*docker_args)
  end
end

module ExecHelpers
  Log = Logger.new($stderr, progname: 'Lighthouse')

  def self.run(*args)
    unless system(*args)
      raise "Command exited with exit status of #{$CHILD_STATUS}"
    end
  end

  # For testing, this is a variable
  @lighthouse_timeout = 4 * 60
  def self.lighthouse_timeout=(val)
    @lighthouse_timeout = val
  end

  def self.limited_system(*args)
    pid = spawn(*args)
    begin
      Timeout.timeout(@lighthouse_timeout) do
        pid, status = Process.wait2(pid)
        return status.success?
      end
    rescue Timeout::Error
      Log.warn "Timeout; killing pid #{pid}"
      Process.kill(15, pid)
      false
    end
  end
end
