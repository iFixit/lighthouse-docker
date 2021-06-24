require 'English'
require 'logger'

module Lighthouse
  Log = Logger.new($stderr, progname: 'Lighthouse')

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
        '--chrome-flags', chrome_flags
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
      '-v', "#{bind_path}:/var/lighthouse/:z",
      'lighthouse',
      '--output-path', target,
      *args
    ]
    Log.info docker_args.join(' ')
    ExecHelpers.limited_system(*docker_args)
  end
end

module ExecHelpers
  def self.run(*args)
    unless system(*args)
      raise "Command exited with exit status of #{$CHILD_STATUS}"
    end
  end

  LIGHTHOUSE_TIMEOUT = 4 * 60

  def self.limited_system(*args)
    pid = spawn(*args)
    begin
      Timeout.timeout(LIGHTHOUSE_TIMEOUT) do
        Process.wait(pid)
      end
      true
    rescue StandardError
      Log.warn "Timeout; killing pid #{pid}"
      Process.kill(15, pid)
      false
    end
  end
end
