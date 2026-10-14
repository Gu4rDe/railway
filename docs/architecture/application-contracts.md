# Application-контракты и границы модулей

Документ фиксирует контракты будущего backend до выбора конкретного Python
web-фреймворка, ORM и СУБД. Контракты описывают намерения приложения, а не
транспортный формат HTTP и не структуру таблиц базы данных.

## Общие правила

- `domain` содержит сущности, value objects, статусы и инварианты.
- `application` содержит use cases, команды, запросы, DTO и порты.
- `infrastructure` реализует порты application-слоя.
- `presentation` преобразует HTTP-запросы в команды/запросы и результаты в API.
- DTO не являются ORM-моделями и не передаются напрямую в domain.
- Ошибки бизнес-правил возвращаются как типизированные application-ошибки:
  `NotFound`, `ValidationError`, `Conflict`, `Forbidden`, `Unauthorized`.

## Контекст identity

### Use cases

| Use case | Вход | Результат |
| --- | --- | --- |
| `Login` | `LoginCommand(identifier, password)` | `AuthSessionDto` |
| `Logout` | `LogoutCommand(session_id)` | `None` |
| `GetCurrentUser` | `session_id` | `CurrentUserDto` |

### DTO

```text
AuthSessionDto:
  session_id
  user_id
  role: administrator | operator | user
  expires_at

CurrentUserDto:
  user_id
  identifier
  name
  role
  station_id: optional
```

Identity выдаёт application-контекстам только подтверждённую роль и
идентификатор пользователя. Модули не читают пароль и внутреннюю сессию
напрямую.

## Контекст infrastructure

### Use cases администратора

| Use case | Вход | Результат |
| --- | --- | --- |
| `CreateStation` | `CreateStationCommand(code, name)` | `StationDto` |
| `DeleteStation` | `DeleteStationCommand(station_id)` | `None` |
| `ListStations` | `ListStationsQuery()` | `list[StationDto]` |
| `CreateOperator` | `CreateOperatorCommand(station_id, name)` | `OperatorCredentialsDto` |
| `DeleteOperator` | `DeleteOperatorCommand(operator_id)` | `None` |
| `ListOperators` | `ListOperatorsQuery()` | `list[OperatorDto]` |
| `CreateTrain` | `CreateTrainCommand(number, route_id)` | `TrainDto` |
| `DeleteTrain` | `DeleteTrainCommand(train_id)` | `None` |
| `ListTrains` | `ListTrainsQuery()` | `list[TrainDto]` |

### DTO

```text
StationDto:
  station_id
  code
  name

OperatorDto:
  operator_id
  user_id
  station_id
  name

OperatorCredentialsDto:
  operator: OperatorDto
  identifier
  temporary_password

TrainDto:
  train_id
  number
  route_id
  status: ready | in_transit | arrived
```

Операции создания и удаления проверяют права администратора. Удаление станции
или поезда должно учитывать активные маршруты и грузы; точная политика
удаления фиксируется в domain-правилах, а не в HTTP-обработчике.

## Контекст routing

Routing не является самостоятельным пользовательским разделом в текущем
use-case-потоке. Он предоставляет application-порты для инфраструктуры и
грузов.

### Запросы

| Запрос | Вход | Результат |
| --- | --- | --- |
| `GetRoute` | `route_id` | `RouteDto` |
| `FindTrainsToStation` | `destination_station_id` | `list[TrainDto]` |
| `CanTravel` | `origin_station_id, destination_station_id` | `bool` |

```text
RouteDto:
  route_id
  station_ids: list[station_id]
```

Routing владеет правилами прохождения маршрута и не знает о пользовательском
интерфейсе. `cargo` обращается к нему через порт поиска поездов и проверки
доступности направления.

## Контекст cargo

### Use cases пользователя

| Use case | Вход | Результат |
| --- | --- | --- |
| `CreateCargoShipment` | `CreateCargoCommand(...)` | `CargoDto` |
| `TrackCargo` | `TrackCargoQuery(cargo_id)` | `CargoTrackingDto` |

### Use cases оператора

| Use case | Вход | Результат |
| --- | --- | --- |
| `AcceptCargo` | `AcceptCargoCommand(cargo_id, station_id)` | `CargoDto` |
| `AssignCargoToTrain` | `AssignCargoCommand(cargo_id, train_id)` | `CargoDto` |
| `CollectCargo` | `CollectCargoCommand(cargo_id, station_id)` | `CargoDto` |

### DTO

```text
CreateCargoCommand:
  sender_id
  description
  weight
  origin_station_id
  destination_station_id

CargoDto:
  cargo_id
  sender_id
  description
  weight
  origin_station_id
  destination_station_id
  assigned_train_id: optional
  status: awaiting_acceptance | accepted_at_station | in_transit | collected

CargoTrackingDto:
  cargo_id
  status
  current_station_id: optional
  assigned_train_id: optional
```

Переходы статуса ограничены domain-правилами:

```text
awaiting_acceptance -> accepted_at_station -> in_transit -> collected
```

При отправке груза cargo проверяет через routing, что станции различаются и
между ними существует маршрут. При распределении cargo запрашивает у routing
поезда до станции назначения и проверяет через infrastructure, что выбранный
поезд существует и доступен. При получении cargo проверяет, что груз находится
в статусе `in_transit`, поезд прибыл, а оператор работает на станции получения.

## Порты application-слоя

Порты объявляются рядом с use cases; конкретные реализации находятся в
`infrastructure`.

### Хранилища

```text
UserRepository
  get_by_id(user_id)
  get_by_identifier(identifier)
  save(user)

StationRepository
  get_by_id(station_id)
  exists_by_code(code)
  list()
  save(station)
  delete(station_id)

OperatorRepository
  get_by_id(operator_id)
  list_by_station(station_id)
  save(operator)
  delete(operator_id)

TrainRepository
  get_by_id(train_id)
  list()
  list_available_to(destination_station_id)
  save(train)
  delete(train_id)

RouteRepository
  get_by_id(route_id)
  exists_between(origin_station_id, destination_station_id)

CargoRepository
  get_by_id(cargo_id)
  list_by_sender(sender_id)
  save(cargo)
```

### Identity и безопасность

```text
PasswordHasher
  hash(raw_password)
  verify(raw_password, password_hash)

SessionStore
  create(user_id, role)
  get(session_id)
  delete(session_id)

CurrentUser
  require_authenticated()
  require_role(role)
```

### Внешние границы

```text
TransactionManager
  begin()
  commit()
  rollback()

IdGenerator
  new_id()

Clock
  now()
```

`TransactionManager` нужен для операций, изменяющих несколько агрегатов или
репозиториев: приём груза, назначение на поезд и получение груза.

## Связи между модулями

```text
identity
  └── предоставляет CurrentUser и роли для application use cases

infrastructure
  ├── владеет Station, Operator и Train
  └── предоставляет проверку существования и доступности поездов

routing
  ├── владеет Route
  └── использует read-порт TrainRepository для поиска поездов

cargo
  ├── владеет Cargo и переходами CargoStatus
  ├── использует identity для проверки отправителя и роли оператора
  ├── использует infrastructure для станций, поездов и привязки оператора
  └── использует routing для проверки маршрутов и поиска поездов
```

Прямой импорт ORM-моделей между модулями запрещён. Если cargo нужен объект из
другого контекста, он получает его через порт, идентификатор или небольшой
DTO. Это сохраняет возможность заменить БД и HTTP-слой без изменения доменных
правил.
