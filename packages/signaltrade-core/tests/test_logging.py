import json
import logging

from signaltrade_core.logging import JsonFormatter, request_id_var


def test_json_formatter_redacts_secrets_and_adds_request_id() -> None:
    token = request_id_var.set("request-1")
    try:
        record = logging.LogRecord("test", logging.INFO, __file__, 1, "done", (), None)
        record.api_key = "private"
        payload = json.loads(JsonFormatter().format(record))
    finally:
        request_id_var.reset(token)

    assert payload["request_id"] == "request-1"
    assert payload["api_key"] == "[REDACTED]"

