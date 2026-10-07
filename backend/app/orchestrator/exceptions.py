"""Excepciones del orquestador."""


class OrchestratorError(Exception):
    def __init__(self, message: str, code: str = "orchestrator_error") -> None:
        self.message = message
        self.code = code
        super().__init__(message)


class OrchestratorRoutingError(OrchestratorError):
    def __init__(self, detail: str) -> None:
        super().__init__(detail, "orchestrator_routing_error")
