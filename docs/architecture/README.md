# Архитектура системы «Железная дорога»

Архитектурный каркас будущего кода находится в `railway/`:

- `railway/backend/` — Python web backend;
- `railway/frontend/` — TypeScript/React frontend.

## Доменные контексты

| Контекст | Ответственность | Основные объекты |
| --- | --- | --- |
| Identity | учётные записи, роли и вход | `User`, `Administrator`, `Operator` |
| Infrastructure | управление станциями, операторами и поездами | `Station`, `Train` |
| Routing | маршруты и доступные направления | `Route` |
| Cargo | отправка, обработка и отслеживание грузов | `Cargo`, `CargoStatus` |

`Train` использует `Route`, а `Cargo` ссылается на станции отправления и
назначения и может быть назначен на поезд. Эти связи должны проходить через
контракты модулей, а не через прямый импорт внутренних моделей.

## Слои backend

- **Domain** — бизнес-правила и инварианты.
- **Application** — сценарии использования и порты.
- **Infrastructure** — БД и внешние реализации портов.
- **Presentation** — HTTP API и преобразование входных/выходных данных.

Подробные правила находятся в
[`railway/backend/README.md`](../../railway/backend/README.md), структура
frontend — в [`railway/frontend/README.md`](../../railway/frontend/README.md).

Application use cases, DTO, порты и связи между контекстами описаны в
[`application-contracts.md`](application-contracts.md).
