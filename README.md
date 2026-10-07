# Pitágoras

Plataforma de preparación para exámenes de admisión universitaria. Combina simulacros, diagnóstico académico, currículo CNEB y tutores IA.

## Estructura del repositorio

```
pitagoras/
├── frontend/              # App Flutter
│   └── lib/
│       ├── core/          # config, theme, router, providers, constants
│       ├── data/          # api, dto, models, repositories
│       ├── features/      # providers por dominio
│       ├── screens/       # pantallas (auth, onboarding, shell, …)
│       └── widgets/       # UI compartida
├── backend/               # API FastAPI
│   ├── app/               # código de la aplicación
│   ├── scripts/
│   │   ├── seed/          # datos iniciales / demo
│   │   ├── migrate/       # migraciones SQL ligeras
│   │   └── curriculum/    # catálogo CNEB + enriquecimiento de teoría
│   ├── data/              # chroma / cachés
│   └── logs/              # logs de ejecución local
├── database/              # schema.sql y migraciones SQL
├── docs/                  # arquitectura, UX, planes
├── tests/                 # unit + integration
├── docker/                # assets Docker (compose está en la raíz)
├── docker-compose.yml     # MySQL local (puerto 3307)
└── _archive/              # copias viejas / material no activo
```

## Stack

| Capa | Tecnología |
|------|------------|
| Cliente | Flutter |
| API | FastAPI |
| BD | MySQL 8 (Docker en `:3307`) |
| Auth | JWT |
| IA | RAG (Chroma) + LLM (OpenRouter / Gemini) |

## Arranque local

### 1. Base de datos

```bash
docker compose up -d
```

Credenciales (ver `docker-compose.yml` / `backend/.env`):

- Host: `localhost:3307`
- DB/user/pass: `pitagoras` / `pitagoras` / `pitagoras`

### 2. Backend

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate          # Windows
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

API docs: http://localhost:8000/docs

### 3. Frontend

```bash
cd frontend
flutter pub get
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5174
```

App: http://localhost:5174

## Scripts útiles (desde `backend/`)

```bash
python -m scripts.seed.seed_demo
python -m scripts.seed.seed_cneb_secondary
python -m scripts.curriculum.enrich_topic_theory --only-missing
```

Detalle: [`backend/scripts/README.md`](backend/scripts/README.md)

## Documentación

| Documento | Contenido |
|-----------|-----------|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Arquitectura y módulos |
| [DATABASE.md](docs/DATABASE.md) | Modelo MySQL |
| [IMPLEMENTATION_GUIDE.md](docs/IMPLEMENTATION_GUIDE.md) | Bitácora de desarrollo |
| [UI_UX_PLAN.md](docs/UI_UX_PLAN.md) | Guía UI/UX |
| [FIGMA_ANALYSIS.md](docs/FIGMA_ANALYSIS.md) | Mapeo pantallas ↔ backend |
