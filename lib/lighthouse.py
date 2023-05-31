import json
import subprocess
from urllib.parse import urlparse
from datadog import DataDogApiClient

class Lighthouse:
    command = ['lighthouse', '--output=json', '--quiet', '--chrome-flags="--headless"']

    def run(self, url):
        command = self.command + [url]
        result = subprocess.run(command, stdout=subprocess.PIPE)

        if result.returncode != 0:
            raise Exception('Lighthouse failed')

        json_results = json.loads(result.stdout)
        metrics = self.parse_json_report(json_results)
        self.send_metrics_to_datadog(url, metrics)


    def parse_json_report(self, json_results):
        # Cumulative Layout Shift
        cumulative_layout_shift = self._get_audits_value(json_results, 'cumulative-layout-shift')

        # Largest Contentful Paint
        largest_contentful_paint = self._get_audits_value(json_results, 'largest-contentful-paint')

        # Total Blocking Time
        total_blocking_time = self._get_audits_value(json_results, 'total-blocking-time')

        # Network Request Total Transfer Size
        page_size = json_results.get('audits').get('diagnostics').get('details').get('items')[0].get('totalByteWeight')

        return {
            'cumulative_layout_shift': cumulative_layout_shift,
            'largest_contentful_paint': largest_contentful_paint,
            'total_blocking_time': total_blocking_time,
            'page_size': page_size
        }


    def _get_audits_value(self, json_results, audit_name):
        return json_results.get('audits').get(audit_name).get('numericValue') or 0

    def send_metrics_to_datadog(self, url, metrics):
        page_path = urlparse(url).path.split('/')[1:]
        if page_path:
            page_type = page_path[0]
        else:
            page_type = 'Home'

        tags = {
            'page_type': page_type,
            'url': url,
            'test': 'test'
        }
        tags = [f'{k}:{v}' for k, v in tags.items()]

        datadog = DataDogApiClient.get_instance()

        for metric_name, value in metrics.items():
            datadog.submit_metric(f'lighthouse.{metric_name}', value, tags)

if __name__ == '__main__':
    lighthouse = Lighthouse()
    lighthouse.run('https://www.ifixit.com')
    lighthouse.run('https://www.ifixit.com/Device/Mac')