"""Mensajes Motivador / Padres sin LLM — plantillas según diagnóstico y plan."""

from __future__ import annotations

from decimal import Decimal

from sqlalchemy.orm import Session

from app.agents.types import AgentResponse
from app.diagnostics.diagnostic_service import DiagnosticService
from app.recommendations.recommendation_service import RecommendationService


def _fmt_score(value: Decimal | float) -> str:
    return f"{float(value):.1f}"


def _first_focus(diagnostic, plan) -> str:
    if plan.focus_subtopics:
        return plan.focus_subtopics[0]
    if diagnostic.weaknesses:
        return diagnostic.weaknesses[0].split("→")[-1].strip()
    if diagnostic.subtopics:
        weakest = min(diagnostic.subtopics, key=lambda item: item.score_percent)
        return weakest.name
    return "Matemática"


def _weakness_labels(diagnostic, limit: int = 2) -> list[str]:
    if diagnostic.weaknesses:
        labels = []
        for item in diagnostic.weaknesses[:limit]:
            if "→" in item:
                labels.append(item.split("→")[-1].strip())
            else:
                labels.append(item)
        return labels
    weak_items = [s for s in diagnostic.subtopics if float(s.score_percent) < 50]
    weak_items.sort(key=lambda item: item.score_percent)
    return [item.name for item in weak_items[:limit]]


class InsightTemplateService:
    """Genera textos personalizados a partir de MySQL, sin consumir tokens."""

    def __init__(self, session: Session) -> None:
        self._session = session
        self._diagnostics = DiagnosticService(session)
        self._recommendations = RecommendationService(session)

    def motivate(
        self,
        student_exam_id: int,
        *,
        student_message: str | None = None,
    ) -> AgentResponse:
        diagnostic = self._diagnostics.get_diagnostic(student_exam_id)
        plan = self._recommendations.get_study_plan(student_exam_id)
        score = float(diagnostic.global_score_percent)
        focus = _first_focus(diagnostic, plan)
        weak = _weakness_labels(diagnostic)

        if student_message and student_message.strip():
            intro = f"Escuchamos tu mensaje: «{student_message.strip()}». "
        else:
            intro = ""

        if score >= 70:
            body = (
                f"{intro}¡Excelente trabajo! Tu puntaje de {_fmt_score(score)}% muestra "
                f"buen dominio. Sigue consolidando con simulacros cortos y repasa {focus} "
                "para mantener el nivel hasta el examen de admisión."
            )
        elif score >= 50:
            weak_text = weak[0] if weak else focus
            body = (
                f"{intro}Vas por buen camino con {_fmt_score(score)}%. "
                f"Con 20–30 minutos diarios enfocados en {weak_text} puedes subir varios puntos. "
                f"Tu plan sugiere unos {plan.estimated_days} días de ritmo constante."
            )
        else:
            weak_text = " y ".join(weak[:2]) if weak else focus
            body = (
                f"{intro}Tu puntaje actual es {_fmt_score(score)}%, y eso es solo el punto de partida. "
                f"Cada simulacro cuenta: empieza hoy por {weak_text} con sesiones cortas. "
                "La constancia importa más que estudiar mucho un solo día."
            )

        return AgentResponse(
            agent_name="pitagoras_motivator",
            student_exam_id=student_exam_id,
            content=body,
            llm_model="template",
            llm_provider="rules",
            metadata={
                "global_score_percent": score,
                "focus": focus,
                "weaknesses": weak,
                "estimated_days": plan.estimated_days,
            },
        )

    def parent_report(self, student_exam_id: int) -> AgentResponse:
        diagnostic = self._diagnostics.get_diagnostic(student_exam_id)
        plan = self._recommendations.get_study_plan(student_exam_id)
        score = float(diagnostic.global_score_percent)
        weak = _weakness_labels(diagnostic, limit=3)
        focus = _first_focus(diagnostic, plan)
        strengths = list(diagnostic.strengths[:2])

        if score >= 70:
            summary = (
                f"Su hijo/a obtuvo {_fmt_score(score)}% en el simulacro diagnóstico. "
                "El rendimiento es sólido para la meta de ingreso a ingenierías."
            )
            support = (
                "Pueden apoyar con un simulacro semanal y revisar juntos las pocas "
                f"preguntas falladas, especialmente en {focus}."
            )
        elif score >= 50:
            summary = (
                f"Alcanzó {_fmt_score(score)}%. Hay base para mejorar con estudio dirigido."
            )
            weak_text = ", ".join(weak[:2]) if weak else focus
            support = (
                f"En casa ayuda una rutina de 15–20 minutos sin presión, reforzando {weak_text}. "
                f"El plan estima unos {plan.estimated_days} días de trabajo constante."
            )
        else:
            summary = (
                f"El puntaje fue {_fmt_score(score)}%. Es normal en una primera medición; "
                "lo importante es la mejora progresiva."
            )
            weak_text = ", ".join(weak[:2]) if weak else focus
            support = (
                f"Sugiere espacio tranquilo para practicar {weak_text}. "
                "Eviten sesiones muy largas; mejor poco cada día. Pueden celebrar cada avance pequeño."
            )

        strength_line = ""
        if strengths:
            strength_line = f"\n\nFortalezas: {', '.join(strengths)}."

        areas_line = ""
        if weak:
            areas_line = f"\n\nÁreas a reforzar: {', '.join(weak)}."

        content = f"{summary}{strength_line}{areas_line}\n\nCómo apoyar en casa: {support}"

        return AgentResponse(
            agent_name="pitagoras_parents",
            student_exam_id=student_exam_id,
            content=content,
            llm_model="template",
            llm_provider="rules",
            metadata={
                "global_score_percent": score,
                "focus": focus,
                "weaknesses": weak,
                "strengths": strengths,
            },
        )

    def analyze_diagnostic(self, student_exam_id: int) -> AgentResponse:
        diagnostic = self._diagnostics.get_diagnostic(student_exam_id)
        plan = self._recommendations.get_study_plan(student_exam_id)
        score = float(diagnostic.global_score_percent)
        focus = _first_focus(diagnostic, plan)
        weak = _weakness_labels(diagnostic, limit=3)
        strengths = [_short_path(s) for s in diagnostic.strengths[:2]]

        if score >= 70:
            summary = (
                f"Puntaje global {_fmt_score(score)}%: perfil sólido para la meta de ingreso. "
                "Conviene mantener ritmo con simulacros cortos."
            )
        elif score >= 50:
            summary = (
                f"Puntaje {_fmt_score(score)}%: hay base, pero el margen de mejora está en "
                f"{', '.join(weak) if weak else focus}."
            )
        else:
            summary = (
                f"Puntaje {_fmt_score(score)}% (primera medición). Prioriza fundamentos en "
                f"{', '.join(weak[:2]) if weak else focus} con sesiones diarias cortas."
            )

        strength_line = f"Fortalezas: {', '.join(strengths)}." if strengths else ""
        weak_line = f"Debilidades: {', '.join(weak)}." if weak else f"Foco: {focus}."
        plan_line = (
            f"Plan estimado: {plan.estimated_days} días. "
            f"Temas prioritarios: {', '.join(plan.focus_subtopics[:3]) or focus}."
        )
        content = " ".join(part for part in [summary, strength_line, weak_line, plan_line] if part)

        return AgentResponse(
            agent_name="pitagoras_diagnostic",
            student_exam_id=student_exam_id,
            content=content,
            llm_model="template",
            llm_provider="rules",
            metadata={
                "global_score_percent": score,
                "focus": focus,
                "weaknesses": weak,
                "strengths": strengths,
            },
        )


def _short_path(text: str) -> str:
    if "→" in text:
        return text.split("→")[-1].strip()
    return text.strip()
