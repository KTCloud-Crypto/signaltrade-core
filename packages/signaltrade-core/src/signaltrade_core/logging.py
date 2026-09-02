from __future__ import annotations

import contextvars
import json
import logging
import re
from datetime import datetime, timezone
from typing import Any

request_id_var: contextvars.ContextVar[str | None] = contextvars.ContextVar(
    "request_id", default=None
)
user_id_var: contextvars.ContextVar[int | None] = contextvars.ContextVar(
    "user_id", default=None
)

_SENSITIVE_KEY = re.compile(
    r"(authorization|cookie|password|secret|token|api[_-]?key|access[_-]?key)",
    re.IGNORECASE,
)
_BEARER = re.compile(r"(?i)bearer\s+[a-z0-9._~+/=-]+")


def sanitize(value: Any, key: str = "") -> Any:
    """Remove credentials from structured log values."""
    if _SENSITIVE_KEY.search(key):
        return "[REDACTED]"
    if isinstance(value, dict):
        return {str(k): sanitize(v, str(k)) for k, v in value.items()}
    if isinstance(value, (list, tuple)):
        return [sanitize(item) for item in value]
    if isinstance(value, str):
        return _BEARER.sub("Bearer [REDACTED]", value)
    if isinstance(value, (int, float, bool)) or value is None:
        return value
    return str(value)


class JsonFormatter(logging.Formatter):
    """One-line JSON formatter with request context and redaction."""

    _standard = set(logging.LogRecord(None, 0, "", 0, "", (), None).__dict__)

    def format(self, record: logging.LogRecord) -> str:
        payload: dict[str, Any] = {
            "timestamp": datetime.fromtimestamp(record.created, timezone.utc).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
        }
        request_id = getattr(record, "request_id", None) or request_id_var.get()
        user_id = getattr(record, "user_id", None) or user_id_var.get()
        if request_id:
            payload["request_id"] = request_id
        if user_id is not None:
            payload["user_id"] = user_id
        for key, value in record.__dict__.items():
            if key not in self._standard and key not in payload and key not in {"args", "msg"}:
                payload[key] = sanitize(value, key)
        if record.exc_info:
            payload["exception"] = self.formatException(record.exc_info)
        return json.dumps(sanitize(payload), ensure_ascii=False, separators=(",", ":"))

