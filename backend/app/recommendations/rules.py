from dataclasses import dataclass
from decimal import Decimal

from app.recommendations.types import ResourceType


@dataclass(frozen=True)
class RecommendationRule:
    """Regla de recomendación basada en rango de porcentaje."""

    id: str
    resource_type: ResourceType
    min_percent: Decimal  # inclusive
    max_percent: Decimal  # inclusive
    priority: int
    message_template: str

    def matches(self, score_percent: Decimal) -> bool:
        return self.min_percent <= score_percent <= self.max_percent

    def format_message(self, entity_name: str) -> str:
        return self.message_template.format(entity=entity_name)


# Reglas por defecto (extensibles vía RecommendationRuleRegistry.register)
DEFAULT_RECOMMENDATION_RULES: list[RecommendationRule] = [
    RecommendationRule(
        id="critical_video",
        resource_type=ResourceType.VIDEO,
        min_percent=Decimal("0"),
        max_percent=Decimal("39.99"),
        priority=10,
        message_template="Refuerza {entity} con videos explicativos (dominio bajo).",
    ),
    RecommendationRule(
        id="practice_exercises",
        resource_type=ResourceType.EXERCISES,
        min_percent=Decimal("40"),
        max_percent=Decimal("70"),
        priority=20,
        message_template="Practica {entity} con ejercicios resueltos y propuestos.",
    ),
    RecommendationRule(
        id="maintain_mock_exam",
        resource_type=ResourceType.MOCK_EXAM,
        min_percent=Decimal("70.01"),
        max_percent=Decimal("100"),
        priority=30,
        message_template="Mantén {entity} con simulacros de repaso.",
    ),
]


class RecommendationRuleRegistry:
    """Registro extensible de reglas de recomendación."""

    def __init__(self, rules: list[RecommendationRule] | None = None) -> None:
        self._rules: list[RecommendationRule] = list(rules or DEFAULT_RECOMMENDATION_RULES)

    @property
    def rules(self) -> list[RecommendationRule]:
        return list(self._rules)

    def register(self, rule: RecommendationRule) -> None:
        self._rules.append(rule)
        self._rules.sort(key=lambda r: r.priority)

    def resolve(self, score_percent: Decimal) -> RecommendationRule | None:
        for rule in sorted(self._rules, key=lambda r: r.priority):
            if rule.matches(score_percent):
                return rule
        return None
