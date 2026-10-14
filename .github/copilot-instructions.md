# Copilot instructions for this repository

## Repository purpose

This repository is a documentation-oriented UML project for a railway system. The source of truth is the PlantUML model files in `uml/`, not application code. Most work here is editing architecture diagrams and keeping generated assets aligned with the `.puml` sources.

## Build, test, and lint commands

There is no Node.js, Python, Go, Java, or other application build system in this repository, and no unit-test or lint target is defined.

For this repo, the relevant validation is focused on rendering the affected PlantUML diagrams:

```bash
./scripts/render-plantuml.sh \
  'uml/use-case-diagram/Связи_диаграммы_вариантов_использования.puml' \
  .
```

Or, when rendering a different diagram or overriding the local PlantUML JAR:

```bash
PLANTUML_JAR=/path/to/plantuml.jar ./scripts/render-plantuml.sh diagram.puml .
```

If you only need to check a single diagram, target that file specifically instead of rerendering everything.

## High-level architecture

The project is organized around diagram artifacts and supporting documentation:

- `uml/use-case-diagram/` contains the use-case diagram(s) for actors and system capabilities.
- `uml/class-diagram/` contains the class diagram for domain entities and relationships.
- `docs/events/`, `docs/guides/`, and `docs/examples/` contain searchable
  Markdown versions of supporting project materials.
- `archive/source-documents/` preserves the original PDF/DOCX source materials.
- `uml-plantuml/` contains the PlantUML generation skill, templates, and the
  project-specific initialization checklist in `init.md`.
- `railway/backend/` is reserved for the Python web backend; `railway/frontend/`
  is reserved for the TypeScript/React web client.
- `docs/architecture/` and `uml/architecture/` describe the planned code
  structure and module boundaries.
- `scripts/render-plantuml.sh` is the single rendering entry point; it resolves a local PlantUML JAR and exports SVG output with the `smetana` layout engine.
- `PLANTUML.md` is the operational reference for local setup, generated artifacts, and PlantUML MCP usage.
- `.vscode/mcp.json` registers a PlantUML MCP server for editor tooling.

The repository is intentionally a static model/documentation project: there is no runtime service, database, or application code to build. The diagram source files (`*.puml`) are the primary artifacts to edit, while generated `*.svg`/`*.png` outputs are visualization products that should remain synchronized with the source. Markdown files are searchable working copies or summaries; archived PDF/DOCX files remain the authoritative originals.

## Key conventions

- Prefer editing the `.puml` source files rather than hand-editing generated images.
- Keep diagram content aligned with the existing naming and structure: use-case diagrams live under `uml/use-case-diagram/`, and the class diagram lives under `uml/class-diagram/`.
- Maintain the project’s established visual conventions (`skinparam`, spacing, actor/use-case styling, and package layout) when editing diagrams.
- Use the repo’s existing PlantUML tooling instead of introducing a different rendering workflow.
- Because this is a diagram-first repository, validation is done by rerendering the impacted `.puml` file and checking that the output still matches the intended architecture.
- Keep filenames descriptive and preserve the current Russian naming in the existing diagram files unless the repository intentionally changes its naming scheme.
- For UML work, follow `uml-plantuml/SKILL.md`, use its templates, and begin
  with the checklist in `uml-plantuml/init.md`.
- Keep backend domain code independent from web frameworks, ORM, and database
  implementations. Backend dependencies should flow from presentation to
  application to domain; infrastructure implements application ports.
- Keep frontend feature modules dependent on API contracts rather than backend
  internals. Kotlin clients, if added later, should consume the same API
  contracts rather than share Python implementation details.
- When adding or revising supporting material, place readable Markdown in the
  matching `docs/` category and keep the original binary source under
  `archive/source-documents/`.

## Additional repo context

- The project documents a railway-system domain model with actors such as Administrator, Station Operator, and User.
- The class diagram and use-case diagram are complementary: the use-case model captures workflows and responsibilities, while the class diagram captures domain entities and relationships.
- The local setup is intentionally lightweight; the main dependency is the PlantUML JAR and, optionally, the PlantUML MCP server configured in VS Code.
