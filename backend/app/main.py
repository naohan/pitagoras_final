from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware

from app.api.v1.router import api_router
from app.core.config import cors_origin_list, settings
from app.core.rate_limit import limiter

app = FastAPI(
    title=settings.api_title,
    version=settings.api_version,
)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.add_middleware(SlowAPIMiddleware)

_local_origins = cors_origin_list()
app.add_middleware(
    CORSMiddleware,
    # Si no hay lista explícita, confía en el regex de desarrollo local.
    allow_origins=_local_origins if _local_origins else [
        "http://localhost:5174",
        "http://127.0.0.1:5174",
        "http://0.0.0.0:5174",
        "http://localhost:5173",
        "http://127.0.0.1:5173",
    ],
    # Flutter web en local puede abrirse como localhost, 127.0.0.1, 0.0.0.0 o IP LAN.
    allow_origin_regex=(
        r"https?://("
        r"localhost|127\.0\.0\.1|0\.0\.0\.0|"
        r"192\.168\.\d{1,3}\.\d{1,3}|"
        r"10\.\d{1,3}\.\d{1,3}\.\d{1,3}|"
        r"172\.(1[6-9]|2\d|3[0-1])\.\d{1,3}\.\d{1,3}"
        r")(:\d+)?"
    ),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix="/api/v1")


@app.get("/health", tags=["Health"])
def health_check() -> dict[str, str]:
    return {"status": "ok"}
