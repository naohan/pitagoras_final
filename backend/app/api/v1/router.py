from fastapi import APIRouter

from app.api.v1 import (
    agents,
    areas,
    auth,
    careers,
    curriculum,
    demo,
    diagnostics,
    exams,
    preparation,
    questions,
    rag,
    recommendations,
    study_activity,
    study_techniques,
    study_tools,
    subtopics,
    topics,
    tutor,
    universities,
)

api_router = APIRouter()

api_router.include_router(auth.router)
api_router.include_router(demo.router)
api_router.include_router(universities.router)
api_router.include_router(careers.router)
api_router.include_router(areas.router)
api_router.include_router(topics.router)
api_router.include_router(subtopics.router)
api_router.include_router(questions.router)
api_router.include_router(exams.router)
api_router.include_router(diagnostics.router)
api_router.include_router(recommendations.router)
api_router.include_router(study_tools.router)
api_router.include_router(study_techniques.router)
api_router.include_router(study_activity.router)
api_router.include_router(curriculum.router)
api_router.include_router(preparation.router)
api_router.include_router(rag.router)
api_router.include_router(agents.router)
api_router.include_router(tutor.router)
