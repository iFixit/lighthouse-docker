import json
import subprocess

class Lighthouse:
    command = ['lighthouse', '--output=json', '--quiet', '--chrome-flags="--headless"']

    def run(self, url):
        command = self.command + [url]
        result = subprocess.run(command, stdout=subprocess.PIPE)
        if result.returncode != 0:
            raise Exception('Lighthouse failed')
        print(json.loads(result.stdout))

if __name__ == '__main__':
    lighthouse = Lighthouse()
    lighthouse.run('localhost:3000')
