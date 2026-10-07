from dataclasses import dataclass, field
from decimal import Decimal

from sqlalchemy.orm import Session

from app.diagnostics.diagnostic_service import DiagnosticItem, DiagnosticReport, DiagnosticService
from app.recommendations.exceptions import NoRecommendationRuleError
from app.recommendations.rules import RecommendationRule, RecommendationRuleRegistry
from app.recommendations.types import ResourceType


@dataclass
class StudyRecommendation:
    entity_type: str
    entity_id: int
    entity_name: str
    score_percent: Decimal
    resource_type: ResourceType
    rule_id: str
    message: str


@dataclass
class StudyPlan:
    student_exam_id: int
    global_score_percent: Decimal
    estimated_days: int
    recommendations: list[StudyRecommendation] = field(default_factory=list)
    focus_subtopics: list[str] = field(default_factory=list)
    by_resource_type: dict[str, list[StudyRecommendation]] = field(default_factory=dict)


class RecommendationService:
    """Genera planes de estudio a partir del diagnóstico y reglas configurables."""

    def __init__(
        self,
        session: Session,
        rule_registry: RecommendationRuleRegistry | None = None,
    ) -> None:
        self._session = session
        self._diagnostics = DiagnosticService(session)
        self._registry = rule_registry or RecommendationRuleRegistry()

    @property
    def rule_registry(self) -> RecommendationRuleRegistry:
        return self._registry

    def get_study_plan(self, student_exam_id: int) -> StudyPlan:
        diagnostic = self._diagnostics.get_diagnostic(student_exam_id)
        recommendations = self._build_recommendations(diagnostic)
        by_type = self._group_by_resource_type(recommendations)
        focus = [
            r.entity_name
            for r in recommendations
            if r.resource_type in (ResourceType.VIDEO, ResourceType.EXERCISES)
        ]

        return StudyPlan(
            student_exam_id=student_exam_id,
            global_score_percent=diagnostic.global_score_percent,
            estimated_days=self._estimate_days(recommendations),
            recommendations=recommendations,
            focus_subtopics=sorted(set(focus)),
            by_resource_type=by_type,
        )

    def list_rules(self) -> list[RecommendationRule]:
        return self._registry.rules

    def _build_recommendations(self, diagnostic: DiagnosticReport) -> list[StudyRecommendation]:
        if diagnostic.subtopics:
            source: list[tuple[str, DiagnosticItem]] = [
                ("subtopic", item) for item in diagnostic.subtopics
            ]
        else:
            source = [("topic", item) for item in diagnostic.topics]

        recommendations: list[StudyRecommendation] = []
        for entity_type, item in source:
            rule = self._registry.resolve(item.score_percent)
            if rule is None:
                raise NoRecommendationRuleError(str(item.score_percent))

            recommendations.append(
                StudyRecommendation(
                    entity_type=entity_type,
                    entity_id=item.entity_id,
                    entity_name=item.name,
                    score_percent=item.score_percent,
                    resource_type=rule.resource_type,
                    rule_id=rule.id,
                    message=rule.format_message(item.name),
                )
            )

        return sorted(recommendations, key=lambda r: r.score_percent)

    def _group_by_resource_type(
        self,
        recommendations: list[StudyRecommendation],
    ) -> dict[str, list[StudyRecommendation]]:
        grouped: dict[str, list[StudyRecommendation]] = {}
        for rec in recommendations:
            key = rec.resource_type.value
            grouped.setdefault(key, []).append(rec)
        return grouped

    def _estimate_days(self, recommendations: list[StudyRecommendation]) -> int:
        focus_count = sum(
            1
            for r in recommendations
            if r.resource_type in (ResourceType.VIDEO, ResourceType.EXERCISES)
        )
        if focus_count == 0:
            return 3
        return min(14, max(3, focus_count))
