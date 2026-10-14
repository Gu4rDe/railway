#!/usr/bin/env bash
set -euo pipefail

plantuml_jar="${PLANTUML_JAR:-$HOME/.local/share/plantuml/plantuml-1.2026.8.jar}"
source_file="${1:-uml/use-case-diagram/Связи_диаграммы_вариантов_использования.puml}"
output_dir="${2:-.}"

if [[ ! -f "$plantuml_jar" ]]; then
  echo "PlantUML JAR not found: $plantuml_jar" >&2
  echo "Set PLANTUML_JAR or download PlantUML 1.2026.8 into ~/.local/share/plantuml." >&2
  exit 1
fi

java -jar "$plantuml_jar" -tsvg -Playout=smetana -o "$output_dir" "$source_file"
