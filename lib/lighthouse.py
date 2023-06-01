import json
import subprocess

class Lighthouse:
    command = ['lighthouse', '--output=json', '--quiet', '--chrome-flags="--headless"']

    def run(self, url):
        command = self.command + [url]
        result = subprocess.run(command, stdout=subprocess.PIPE)

        if result.returncode != 0:
            raise Exception('Lighthouse failed')

        return json.loads(result.stdout)

if __name__ == '__main__':
    lighthouse = Lighthouse()
    json_result = lighthouse.run('https://www.ifixit.com')
    # Save the json_result to a file for debugging
    with open('lighthouse.json', 'w') as f:
        json.dump(json_result, f, indent=4)