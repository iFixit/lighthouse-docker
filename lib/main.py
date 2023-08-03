import json
from lighthouse import Lighthouse
from datadog_api import DataDogApiClient
from urllib.parse import urlparse
from dotenv import load_dotenv
load_dotenv()

def retrieve_values_for_audits(json_results, audits):
   metrics = {}
   for audit in audits:
        metrics[audit] = get_audits_value(json_results, audit)
   return metrics

def get_audits_value(json_results, audit_name):
    return json_results.get('audits').get(audit_name).get('numericValue') or 0

def send_metrics_to_datadog(metrics, tags={}):
    tags = [f'{k}:{v}' for k, v in tags.items()]

    dd_client = DataDogApiClient()

    for metric_name, value in metrics.items():
        dd_client.submit_metric(f'lighthouse.{metric_name}', value, tags)

def main():
    lighthouse = Lighthouse()
    with open('urls.json') as f:
        urls = json.load(f)

    with open('metrics-config.json') as f:
        metrics_config = json.load(f)
        audits = metrics_config.get('audits')

    for page_type, url_list in urls.items():
        print(f'Running Lighthouse for {page_type} pages\n')

        for url in url_list:
            try:
                print(f'Running lighthouse for {url}')
                json_results = lighthouse.run(url)
                print(f'Finished running lighthouse for {url}\n')

                print(f'Parsing lighthouse results for {url}\n')
                metrics = retrieve_values_for_audits(json_results, audits)

                print(f'Sending metrics to datadog for {url}')
                send_metrics_to_datadog(metrics, tags = {
                    'url': url,
                    'page_type': page_type,
                    'lighthouse_version': json_results.get('lighthouseVersion'),
                })

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