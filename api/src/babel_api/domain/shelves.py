"""Shelves: lists of books a reader makes in their library."""

from dataclasses import dataclass
from datetime import datetime
from typing import Any
from uuid import UUID

from babel_api.domain.sync import Visibility

MAX_SHELF_NAME = 80
MAX_SHELF_ITEMS = 5000
MAX_SHELVES = 200


@dataclass(frozen=True, slots=True)
class Shelf:
    """An ordered list of library items. Edited as a whole: the latest edit wins."""

    id: UUID
    user_id: UUID
    name: str
    item_ids: tuple[UUID, ...]
    visibility: Visibility
    client_time: datetime

    def as_data(self) -> dict[str, Any]:
        return {
            "id": str(self.id),
            "name": self.name,
            "item_ids": [str(i) for i in self.item_ids],
            "visibility": self.visibility.value,
            "client_time": self.client_time.isoformat(),
        }
