# Repository Guidelines

## Project Structure & Module Organization

This repository contains railway-system design documents and UML assets. `docs/` holds architecture contracts, event flows, report examples, and formatting guidance; original DOCX/PDF sources are in `archive/source-documents/`. Keep PlantUML sources and their rendered PNG/SVG files together under the matching `uml/` diagram-type directory. Diagram authoring guidance and templates are in `uml-plantuml/`. `railway/backend/` and `railway/frontend/` describe planned application modules; executable application code and tests are not yet established.

## Build, Test, and Development Commands

There is no repository-wide build or test command configured yet. To render one diagram and its image outputs, run:

```bash
./scripts/render-plantuml.sh 'uml/use-case-diagram/Связи_диаграммы_вариантов_использования.puml' .
```

Set `PLANTUML_JAR=/path/to/plantuml.jar` if the script cannot find the local PlantUML installation. Rendered files belong beside their `.puml` source. Review the generated image for readability as well as checking syntax.

## Coding Style & Naming Conventions

Write documentation in concise Markdown, following the existing Russian-language domain terminology and relative-link style. Use descriptive Russian filenames for domain diagrams, with lowercase extensions such as `.puml`, `.png`, and `.svg`. In PlantUML, keep one diagram per file, use UTF-8, and follow `uml-plantuml/SKILL.md` for notation, layout, and rendering conventions. Keep application boundaries aligned with `docs/architecture/application-contracts.md`.

## Testing Guidelines

No automated test framework or coverage threshold is configured. For diagram changes, regenerate PNG and SVG outputs and inspect them; for documentation-only changes, check links and consistency with the architecture contracts. Run `git diff --check` before committing.

## Commit & Pull Request Guidelines

Recent history uses short imperative summaries, commonly with conventional prefixes such as `docs:` and `chore:` (for example, `docs: update railway UML diagrams`). Keep each commit focused on one change. Pull requests should summarize the affected documents or diagrams and include regenerated visuals when UML changes affect their output. Link related issues when applicable.

## Security & Configuration

Do not commit machine-specific MCP settings, credentials, or local tool paths. Keep shared configuration portable and document any required local setup.
