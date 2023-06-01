from datadog_api_client.configuration import Configuration
from datadog_api_client.api_client import ApiClient
from datadog_api_client.v2.api import metrics_api
from datadog_api_client.v2.model.metric_point import MetricPoint
from datadog_api_client.v2.model.metric_series import MetricSeries
from datadog_api_client.v2.model.metric_payload import MetricPayload
from datadog_api_client.v2.model.metric_intake_type import MetricIntakeType
import os, time


class DataDogApiClient:
    __instance = None

    @staticmethod
    def get_instance():
        if DataDogApiClient.__instance == None:
            return DataDogApiClient()
        return DataDogApiClient.__instance

    def __init__(self):
        """ Virtually private constructor. """
        if DataDogApiClient.__instance != None:
            raise Exception("This class is a singleton!")
        else:
            DataDogApiClient.__instance = self
            configuration = Configuration()
            api_client = ApiClient(configuration)

            configuration.api_key["apiKeyAuth"] = os.getenv('DD_API_KEY')
            configuration.api_key["appKeyAuth"] = os.getenv('DD_APPLICATION_KEY')

            self.metrics_api_instance = metrics_api.MetricsApi(api_client)

    def submit_metric(self, metric_name, value, tags=[]):
        metric = MetricSeries(
            metric=metric_name,
            points=[
                MetricPoint(
                    timestamp=int(time.time()),
                    value=value
                )
            ],
            type=MetricIntakeType.GAUGE,
            tags=tags
        )

        metrics_payload = MetricPayload(
            series=[metric]
        )

        self.metrics_api_instance.submit_metrics(body=metrics_payload)


if __name__ == '__main__':
    tags = {'url': 'https://www.ifixit.com', 'test': 'test'}
    tags = [f'{k}:{v}' for k, v in tags.items()]

    datadog = DataDogApiClient.get_instance()
    datadog.submit_metric('lighthouse.cumulative_layout_shift', 0.5, tags)
    datadog.submit_metric('lighthouse.largest_contentful_paint', 0.3,  tags)
    datadog.submit_metric('lighthouse.total_blocking_time', 1.231,  tags)
    datadog.submit_metric('lighthouse.page_size', 155129,  tags)