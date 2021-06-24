def run(*args)
  unless system(*args)
    raise "Command exited with exit status of #{$CHILD_STATUS}"
  end
end

LIGHTHOUSE_TIMEOUT = 4 * 60

def limited_system(*args)
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

def lighthouse(
      bind_path,
      target,
      *args,
      chrome_flags: '--headless --no-sandbox'
    )
  docker_args = [
    'docker', 'run',
    '--rm',
    '-v', "#{bind_path}:/var/lighthouse/:z",
    'lighthouse',
    '--chrome-flags', chrome_flags,
    '--output-path', target,
    *args,
  ]
  Log.info docker_args.join(' ')
  limited_system *docker_args
end
