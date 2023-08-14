import json
import subprocess
import shutil

def is_lighthouse_installed_locally():
    try:
        result = subprocess.run(['npm', 'list', 'lighthouse'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output = result.stdout.decode('utf-8')
        if 'lighthouse@' in output:
            return True
        return False
    except Exception as e:
        print(f"An error occurred: {e}")
        return False

def is_lighthouse_installed_globally():
    try:
        result = subprocess.run(['npm', 'list', '-g', 'lighthouse'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output = result.stdout.decode('utf-8')
        if 'lighthouse@' in output:
            return True
        return False
    except Exception as e:
        print(f"An error occurred: {e}")
        return False

def is_browser_installed(browser_name):
    return shutil.which(browser_name) is not None

class Lighthouse:
    def __init__(self):
        # Check if the lighthouse cli package is installed locally
        if not is_lighthouse_installed_globally() and not is_lighthouse_installed_locally():
            raise Exception('Lighthouse package is not installed.\nPlease install it with `npm install -g lighthouse` or `npm install lighthouse`')

        chrome_installed = is_browser_installed("chrome") or is_browser_installed("google-chrome")
        chromium_installed = is_browser_installed("chromium") or is_browser_installed("chromium-browser")

        # Check if chrome or chromium is installed
        if not chrome_installed and not chromium_installed:
            raise Exception('Chrome or Chromium is not installed.\nPlease install it and try again.')

        self.command = ['lighthouse']
        self.lighthouse_options = [
            '--no-enable-error-reporting',
            '--chrome-flags="--headless"',
            '--output=json',
            '--quiet',
        ]

    def run(self, url, options=[]):
        options = options + self.lighthouse_options
        command = self.command + options + [url]
        print(f'Running command: {command}')
        result = subprocess.run(command, stdout=subprocess.PIPE)

        if result.returncode != 0:
            output = result.stdout.decode('utf-8')
            print(output)
            raise Exception('Lighthouse failed')

        return json.loads(result.stdout)

if __name__ == '__main__':
    lighthouse = Lighthouse()
    json_result = lighthouse.run('https://www.ifixit.com', ['--preset=desktop'])
    # # Save the json_result to a file for debugging
    with open('lighthouse.json', 'w') as f:
        json.dump(json_result, f, indent=4)