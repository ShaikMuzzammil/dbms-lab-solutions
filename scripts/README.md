# Screenshot Generator Scripts

These Python scripts are used to regenerate the PNG screenshots in each
exercise's `screenshots/` folder.

| File | Purpose |
|------|---------|
| `screenshot_engine.py` | Core engine: SQLite bootstrap, MySQL-syntax adapter, MySQL-CLI PNG renderer. |
| `generate_screenshots.py` | Per-exercise driver: parses each `queries.sql`, calls the engine, writes PNGs. |

## Why SQLite?

The worksheet is taught using MySQL, but no MySQL server is required to
*regenerate* the screenshots. The engine loads `schema/00_setup_database.sql`
into an in-memory SQLite database with conservative syntax adaptations
(`VARCHAR2` → `VARCHAR`, `NUMBER` → `NUMERIC`, `MINUS` → `EXCEPT`, etc.).
The actual `.sql` files in each exercise folder target MySQL 8.

## Regenerating screenshots

```bash
pip install pillow
python3 scripts/generate_screenshots.py
```

The engine writes one PNG per logical section in each exercise, plus a
composite `_overview.png` for quick visual reference.
