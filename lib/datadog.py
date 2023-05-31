from datadog_api_client.configuration import Configuration
from datadog_api_client.api_client import ApiClient
import os, time
from datadog_api_client.v2.api import metrics_api
from datadog_api_client.v2.model.metric_point import MetricPoint
from datadog_api_client.v2.model.metric_series import MetricSeries
from datadog_api_client.v2.model.metric_payload import MetricPayload
from datadog_api_client.v2.model.metric_intake_type import MetricIntakeType
import os

from dotenv import load_dotenv
load_dotenv()

configuration = Configuration()
api_client = ApiClient(configuration)

configuration.api_key["apiKeyAuth"] = os.getenv('DD_API_KEY')
configuration.api_key["appKeyAuth"] = os.getenv('DD_APPLICATION_KEY')

from datadog_api_client.v1.model.point import Point

metric = MetricSeries(
    metric="lighthouse.cumulative_layout_shift",
    points=[
        MetricPoint(
            timestamp=int(time.time()),
            value=0.1
        )
    ],
    type=MetricIntakeType.GAUGE,
)

metrics_payload = MetricPayload(
    series=[metric]
)

metrics_api_instance = metrics_api.MetricsApi(api_client)
metrics_api_instance.submit_metrics(body=metrics_payload)
