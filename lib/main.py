from lighthouse import Lighthouse
from datadog_api import DataDogApiClient
from urllib.parse import urlparse
from dotenv import load_dotenv
load_dotenv()

urls = [
    'https://www.ifixit.com',
    'https://www.ifixit.com/Device/Mac',
    'https://www.ifixit.com/Guide/How+Install+a+Mac+SSD+into+an+OWC+Envoy+Pro+Enclosure/120579',
    'https://www.ifixit.com/News/76148/ifixit-has-genuine-parts-for-repairing-hp-laptops',
    'https://www.ifixit.com/Parts',
    'https://www.ifixit.com/Tools',
    'https://www.ifixit.com/Answers',
    'https://www.ifixit.com/Answers/View/791009/How+to+remove+iCloud+Activation+Lock'
]

def parse_json_report(json_results):
    # Cumulative Layout Shift
    cumulative_layout_shift = get_audits_value(json_results, 'cumulative-layout-shift')

    # Largest Contentful Paint
    largest_contentful_paint = get_audits_value(json_results, 'largest-contentful-paint')

    # Total Blocking Time
    total_blocking_time = get_audits_value(json_results, 'total-blocking-time')

    # Network Request Total Transfer Size
    page_size = json_results.get('audits').get('diagnostics').get('details').get('items')[0].get('totalByteWeight')

    return {
        'cumulative_layout_shift': cumulative_layout_shift,
        'largest_contentful_paint': largest_contentful_paint,
        'total_blocking_time': total_blocking_time,
        'page_size': page_size
    }

def get_audits_value(json_results, audit_name):
    return json_results.get('audits').get(audit_name).get('numericValue') or 0

def send_metrics_to_datadog(url, metrics):
    page_path = urlparse(url).path.split('/')[1:]
    if page_path:
        page_type = page_path[0]
    else:
        page_type = 'Home'

    tags = {
        'page_type': page_type,
        'url': url,
    }
    tags = [f'{k}:{v}' for k, v in tags.items()]

    dd_client = DataDogApiClient()

    for metric_name, value in metrics.items():
        dd_client.submit_metric(f'lighthouse.{metric_name}', value, tags)

def main():
    lighthouse = Lighthouse()

    for url in urls:
        try:
            print(f'Running lighthouse for {url}')
            json_results = lighthouse.run(url)
            print(f'Finished running lighthouse for {url}\n')

            print(f'Parsing lighthouse results for {url}\n')
            metrics = parse_json_report(json_results)

            print(f'Sending metrics to datadog for {url}')
            send_metrics_to_datadog(url, metrics)

            print(f'Finished sending metrics to datadog for {url}\n')

            print('=' * 80)
        except Exception as e:
            error_message = f'Failed to run lighthouse for {url}: {e}'
            print(error_message)
            raise Exception(error_message)

    print('Finished running lighthouse for all urls')

if __name__ == '__main__':
    main()