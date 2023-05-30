import json
import subprocess

class Lighthouse:
    command = ['lighthouse', '--output=json', '--quiet', '--chrome-flags="--headless"']

    def run(self, url):
        command = self.command + [url]
        result = subprocess.run(command, stdout=subprocess.PIPE)

        if result.returncode != 0:
            raise Exception('Lighthouse failed')

        # save json to a file
        with open('lighthouse.json', 'w') as f:
            f.write(result.stdout.decode('utf-8'))

        json_results = json.loads(result.stdout)

    def parse_json_report(self, json_results):
        # Cumulative Layout Shift
        cumulative_layout_shift = self._get_audits_value(json_results, 'cumulative-layout-shift')
        print('Cumulative Layout Shift: ', cumulative_layout_shift)

        # Largest Contentful Paint
        largest_contentful_paint = self._get_audits_value(json_results, 'largest-contentful-paint')
        print('Largest Contentful Paint: ', largest_contentful_paint)

        # Total Blocking Time
        total_blocking_time = self._get_audits_value(json_results, 'total-blocking-time')
        print('Total Blocking Time: ', total_blocking_time)

        # Network Request Total Transfer Size
        page_size = json_results.get('audits').get('diagnostics').get('details').get('items')[0].get('totalByteWeight')
        print('Page Size: ', page_size)

    def _get_audits_value(self, json_results, audit_name):
        return json_results.get('audits').get(audit_name).get('numericValue') or 0

if __name__ == '__main__':
    lighthouse = Lighthouse()
    # lighthouse.run('https://www.ifixit.com')
    json_results = json.load(open('lighthouse.json'))
    lighthouse.parse_json_report(json_results)
