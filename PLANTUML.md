# PlantUML

Локально подготовлены:

- PlantUML `1.2026.8`: `~/.local/share/plantuml/plantuml-1.2026.8.jar`
- MCP-сервер `@plantuml/mcp-js@0.2.2`, запускаемый через `npx`
- MCP-конфигурация для VS Code: `.vscode/mcp.json`

## Рендеринг

Исходники диаграмм и их готовые изображения находятся вместе в тематических
папках `uml/class-diagram/` и `uml/use-case-diagram/`. Для текущих диаграмм
используется встроенный движок Smetana, поэтому
для базового SVG-рендеринга не требуется системный Graphviz:

```bash
./scripts/render-plantuml.sh \
  'uml/use-case-diagram/Связи_диаграммы_вариантов_использования.puml' \
  .
```

Диаграмма классов находится отдельно:

```text
uml/class-diagram/Диаграмма_классов.puml
uml/class-diagram/Диаграмма_классов.svg
uml/class-diagram/Диаграмма_классов.png
```

Файлы диаграммы вариантов использования находятся в:

```text
uml/use-case-diagram/
```

Дополнительные UML-диаграммы находятся в тематических папках:

```text
uml/activity-diagram/    # потоки деятельности
uml/state-diagram/       # состояния груза
uml/sequence-diagram/    # сценарии взаимодействия
uml/component-diagram/   # компоненты системы
uml/deployment-diagram/  # физическое развёртывание
```

Каждый новый исходник `.puml` рендерится в PNG и SVG рядом с исходником.
Для массовой проверки можно использовать локальный PlantUML JAR:

```powershell
java -jar ~/.local/share/plantuml/plantuml-1.2026.8.jar `
  -charset UTF-8 -tsvg -tpng -Playout=smetana `
  uml/activity-diagram/*.puml
```

Текстовые материалы находятся в `docs/`:

- `docs/events/` — потоки событий железнодорожной системы;
- `docs/guides/` — требования к оформлению ВКР;
- `docs/examples/` — структурный разбор примера отчёта.
- `docs/architecture/` — описание будущей модульной архитектуры приложения.

Будущий код организуется в `railway/`: Python backend находится в
`railway/backend/`, а TypeScript/React frontend — в `railway/frontend/`.
Архитектурная диаграмма приложения находится в
`uml/architecture/Архитектура_приложения.puml`.

Исходные PDF и DOCX сохранены в `archive/source-documents/` и используются как
первоисточники для Markdown-версий.

Правила подготовки новых диаграмм и шаблоны находятся в `uml-plantuml/`.
Перед работой прочитай `uml-plantuml/init.md`, затем используй рекомендации
`uml-plantuml/SKILL.md` и шаблоны из `uml-plantuml/references/templates.md`.

Можно указать другой JAR:

```bash
PLANTUML_JAR=/path/to/plantuml.jar ./scripts/render-plantuml.sh diagram.puml .
```

## MCP

`.vscode/mcp.json` подключает MCP-сервер по stdio. После перезапуска MCP-клиента
доступны инструменты проверки синтаксиса, рендеринга SVG, объяснения диаграммы и
получения версии PlantUML.

Для ручной проверки запуска:

```bash
npx -y @plantuml/mcp-js@0.2.2
```

Команда ожидает MCP-клиент и поэтому остаётся запущенной; это нормальное
поведение stdio-сервера. Сервер рендерит SVG и не требует Java или системного
Graphviz. Для PNG/PDF нужен Java-based MCP-сервер и дополнительные зависимости.
