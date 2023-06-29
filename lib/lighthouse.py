import json
import subprocess

class Lighthouse:
    IMAGE_NAME = 'lighthouse'

    def __init__(self):
        # Check if the lighthouse image is locally saved
        result = subprocess.run(['docker', 'images', self.IMAGE_NAME], stdout=subprocess.PIPE)
        if result.returncode != 0 or self.IMAGE_NAME not in result.stdout.decode():
            raise Exception(f'{self.IMAGE_NAME} image not found.\nTry running: `docker build -t {self.IMAGE_NAME} ./lighthouse-docker`')

        self.command = [
            'docker', 'run',
            '--rm',
            '--name', 'lighthouse',
            self.IMAGE_NAME
        ]

        self.lighthouse_options = [
            '--output=json',
            '--quiet',
        ]

    def run(self, url):
        command = self.command + [url] + self.lighthouse_options
        result = subprocess.run(command, stdout=subprocess.PIPE)

        if result.returncode != 0:
            output = result.stdout.decode('utf-8')
            print(output)
            raise Exception('Lighthouse failed')

        return json.loads(result.stdout)

if __name__ == '__main__':
    lighthouse = Lighthouse()
    json_result = lighthouse.run('https://www.ifixit.com')
    # Save the json_result to a file for debugging
    with open('lighthouse.json', 'w') as f:
        json.dump(json_result, f, indent=4)