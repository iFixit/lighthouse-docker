import datadog
import os, time

class DataDogApiClient:
    def __init__(self):
        options = {
            "api_key": os.getenv('DD_API_KEY'),
            "app_key": os.getenv('DD_APPLICATION_KEY')
        }

        datadog.initialize(**options)

    def submit_metric(self, metric_name, value, tags=[]):
        metric = [
            {
                'metric': metric_name,
                'type': 'gauge',
                'points': [
                    (int(time.time()), value)
                ],
                'tags': tags
            }
        ]

        datadog.api.Metric.send(metrics=metric)


if __name__ == '__main__':
    tags = {'url': 'https://www.ifixit.com', 'test': 'test'}
    tags = [f'{k}:{v}' for k, v in tags.items()]

    dd_client = DataDogApiClient()
    dd_client.submit_metric('lighthouse.cumulative_layout_shift', 0.5, tags)

    dd_client = DataDogApiClient()
    dd_client.submit_metric('lighthouse.largest_contentful_paint', 0.3, tags)

    dd_client = DataDogApiClient()
    dd_client.submit_metric('lighthouse.total_blocking_time', 1.231, tags)

    dd_client = DataDogApiClient()
    dd_client.submit_metric('lighthouse.page_size', 155129, tags)