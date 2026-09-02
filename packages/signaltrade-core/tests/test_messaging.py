from datetime import datetime

import pytest
from pydantic import ValidationError

from signaltrade_core.messaging import MessageEnvelope


def test_message_envelope_round_trip() -> None:
    envelope = MessageEnvelope.create(
        message_type="StrategySignalCreated",
        producer="signaltrade-strategy",
        payload={"signal_id": 42},
        idempotency_key="signal:42",
    )

    restored = MessageEnvelope.from_json(envelope.to_json())

    assert restored == envelope
    assert restored.correlation_id == str(restored.message_id)


def test_message_envelope_rejects_naive_timestamp() -> None:
    with pytest.raises(ValidationError):
        MessageEnvelope(
            message_type="StrategySignalCreated",
            occurred_at=datetime(2026, 1, 1),
            correlation_id="correlation-1",
            producer="signaltrade-strategy",
        )
