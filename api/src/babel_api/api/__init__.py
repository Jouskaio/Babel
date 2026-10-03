"""HTTP layer: routes, request/response schemas, FastAPI dependencies.

Rule: this layer translates HTTP ↔ use cases. It calls ``services`` and contains neither
business logic nor direct calls to external services.
"""
