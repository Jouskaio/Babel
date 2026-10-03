"""Use cases: orchestrate the domain and the adapters.

Rule: depend on the domain and on interfaces (``typing.Protocol``) implemented by
``adapters`` — never on a concrete HTTP client — so they stay testable.
"""
