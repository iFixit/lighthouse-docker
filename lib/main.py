import json
from lighthouse import Lighthouse
from datadog_api import DataDogApiClient
from urllib.parse import urlparse
from dotenv import load_dotenv
load_dotenv()

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

def send_metrics_to_datadog(page_type, url, metrics):
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
    with open('urls.json') as f:
        urls = json.load(f)

    for page_type, url_list in urls.items():
        print(f'Running Lighthouse for {page_type} pages\n')

        for url in url_list:
            try:
                print(f'Running lighthouse for {url}')
                json_results = lighthouse.run(url)
                print(f'Finished running lighthouse for {url}\n')

                print(f'Parsing lighthouse results for {url}\n')
                metrics = parse_json_report(json_results)

                print(f'Sending metrics to datadog for {url}')
                send_metrics_to_datadog(page_type, url, metrics)

                print(f'Finished sending metrics to datadog for {url}\n')

                print('=' * 80)
            except Exception as e:
                error_message = f'Failed to run lighthouse for {url}: {e}'
                print(error_message)
                raise Exception(error_message)

        print(f'Finished running lighthouse for all urls of {page_type} pages\n')
    print(f'Finished running lighthouse for all urls\n')

if __name__ == '__main__':
    main()