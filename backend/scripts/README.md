# Scripts del backend

Ejecutar siempre desde `backend/` con el venv activo.

## seed/ — datos iniciales
- `python -m scripts.seed.seed_demo`
- `python -m scripts.seed.seed_cneb_secondary`
- `python -m scripts.seed.seed_hackathon_demo`
- `python -m scripts.seed.seed_academic`

## migrate/ — cambios de esquema
- `python -m scripts.migrate.migrate_subtopic_theory`
- `python -m scripts.migrate.migrate_preparation_profile`

## curriculum/ — catálogo CNEB + teoría
- `python -m scripts.curriculum.enrich_topic_theory`
- Fuentes: `cneb_catalog.py`, `cneb_extra_topics.py`, `wiki_titles.py`
