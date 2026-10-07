"""Excepciones del sistema de recomendaciones."""


class RecommendationError(Exception):
    def __init__(self, message: str, code: str = "recommendation_error") -> None:
        self.message = message
        self.code = code
        super().__init__(message)


class NoRecommendationRuleError(RecommendationError):
    def __init__(self, score_percent: str) -> None:
        super().__init__(
            f"No recommendation rule matches score {score_percent}%",
            "no_matching_rule",
        )
