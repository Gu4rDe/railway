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
- Application получает актёра из подтверждённой сессии. Для оператора
  `station_id` всегда берётся из `CurrentUser`, а не доверяется входному DTO.

## Контекст identity

### Use cases

| Use case | Вход | Результат | Доступ |
| --- | --- | --- | --- |
| `Login` | `LoginCommand(identifier, password)` | `AuthSessionDto` | все роли |
| `Logout` | `LogoutCommand(session_id)` | `None` | текущая сессия |
| `GetCurrentUser` | `session_id` | `CurrentUserDto` | текущая сессия |
| `CreateUser` | `CreateUserCommand(name)` | `UserCredentialsDto` | администратор |

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

UserCredentialsDto:
  user_id
  identifier
  temporary_password
```

Администратор создаёт учётную запись пользователя; система генерирует
идентификатор и временный пароль, которые показываются администратору один раз.
Identity выдаёт application-контекстам только подтверждённую роль и
идентификатор пользователя. Модули не читают пароль и внутреннюю сессию
напрямую.

## Контекст infrastructure

### Use cases

| Use case | Вход | Результат | Доступ |
| --- | --- | --- | --- |
| `CreateStation` | `CreateStationCommand(code, name)` | `StationDto` | администратор |
| `DeleteStation` | `DeleteStationCommand(station_id)` | `None` | администратор |
| `ListStations` | `ListStationsQuery()` | `list[StationDto]` | все роли |
| `CreateOperator` | `CreateOperatorCommand(station_id, name)` | `OperatorCredentialsDto` | администратор |
| `DeleteOperator` | `DeleteOperatorCommand(operator_id)` | `None` | администратор |
| `ListOperators` | `ListOperatorsQuery()` | `list[OperatorDto]` | администратор |
| `CreateTrain` | `CreateTrainCommand(number, origin_station_id, destination_station_id)` | `TrainDto` | администратор |
| `DeleteTrain` | `DeleteTrainCommand(train_id)` | `None` | администратор |
| `ListTrains` | `ListTrainsQuery()` | `list[TrainDto]` | администратор |
| `RegisterTrainArrival` | `RegisterTrainArrivalCommand(train_id)` | `TrainDto` | оператор своей станции |

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
  origin_station_id
  destination_station_id
  status: ready | in_transit | arrived
```

Поезд обслуживает прямое направление между начальной и конечной станциями;
промежуточные станции и пересадки в текущей модели не поддерживаются.
Создание и удаление проверяют права администратора. Регистрация прибытия
проверяет, что конечная станция поезда совпадает со станцией текущего оператора.
Удаление станции или поезда учитывает связанные грузы; ограничения фиксируются
в domain-правилах.

## Контекст routing

Routing предоставляет application-порты для проверки прямого сообщения и
поиска поездов. Отдельных пользовательских операций управления маршрутами нет.

| Запрос | Вход | Результат |
| --- | --- | --- |
| `FindTrainsBetweenStations` | `origin_station_id, destination_station_id` | `list[TrainDto]` |
| `CanTravel` | `origin_station_id, destination_station_id` | `bool` |

`CanTravel` возвращает `true`, если существует поезд по прямому направлению.
`FindTrainsBetweenStations` возвращает поезда, проходящие ровно между указанными
начальной и конечной станциями и доступные для назначения.

## Контекст cargo

### Use cases пользователя или получателя

| Use case | Вход | Результат | Доступ |
| --- | --- | --- | --- |
| `CreateCargoShipment` | `CreateCargoCommand(...)` | `CargoDto` | пользователь |
| `TrackCargo` | `TrackCargoQuery(cargo_id)` | `CargoTrackingDto` | отправитель или получатель |
| `ConfirmCargoPickup` | `ConfirmCargoPickupCommand(cargo_id)` | `CargoDto` | назначенный получатель |

### Use cases оператора

| Use case | Вход | Результат | Доступ |
| --- | --- | --- | --- |
| `ListStationCargo` | `ListStationCargoQuery(status?)` | `list[CargoSummaryDto]` | оператор своей станции |
| `AcceptCargo` | `AcceptCargoCommand(cargo_id)` | `CargoDto` | оператор станции отправления |
| `AssignCargoToTrain` | `AssignCargoCommand(cargo_id, train_id)` | `CargoDto` | оператор станции отправления |
| `UnloadCargo` | `UnloadCargoCommand(cargo_id)` | `CargoDto` | оператор станции назначения |

### DTO

```text
CreateCargoCommand:
  recipient_id
  description
  weight
  origin_station_id
  destination_station_id

CargoDto:
  cargo_id
  sender_id
  recipient_id
  description
  weight
  origin_station_id
  destination_station_id
  assigned_train_id: optional
  status: awaiting_acceptance | accepted_at_station | in_transit |
          available_for_pickup | collected

CargoTrackingDto:
  cargo_id
  status
  current_station_id: optional
  assigned_train_id: optional

CargoSummaryDto:
  cargo_id
  description
  weight
  status
  origin_station_id
  destination_station_id
  current_station_id: optional
  assigned_train_id: optional
```

Создание отправления создаёт груз со статусом `awaiting_acceptance`. Оператор
принимает этот же груз по `cargo_id`; он не создаёт дубликат и не вводит повторно
данные отправителя. `ListStationCargo` выводит только грузы станции оператора;
параметр `status` фильтрует этот список. `TrackCargo` возвращает результат
только отправителю или получателю груза. Получатель подтверждает выдачу только
для назначенного ему груза.

Переходы статуса ограничены domain-правилами:

```text
awaiting_acceptance -> accepted_at_station -> in_transit
                   -> available_for_pickup -> collected
```

При отправке cargo проверяет через routing, что станции различаются и между
ними есть прямое сообщение. При распределении cargo проверяет, что выбранный
поезд соответствует начальной и конечной станциям груза, а оператор работает
на станции отправления. Оператор регистрирует прибытие поезда в infrastructure;
затем `UnloadCargo` проверяет статус `arrived`, конечную станцию и переводит
груз в `available_for_pickup`. `ConfirmCargoPickup` переводит груз в `collected`.

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
  list_available_between(origin_station_id, destination_station_id)
  save(train)
  delete(train_id)

CargoRepository
  get_by_id(cargo_id)
  list_by_station(station_id, status?)
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
  require_station_operator()
```

### Внешние границы

```text
TransactionManager
  begin()
  commit()
  rollback()

IdGenerator
  new_id()

CredentialGenerator
  new_identifier()
  new_temporary_password()

Clock
  now()
```

`TransactionManager` нужен для операций, изменяющих несколько агрегатов или
репозиториев: приёма груза, назначения поезда, регистрации прибытия с обновлением
грузов, выгрузки и выдачи получателю.

## Связи между модулями

```text
identity
  └── предоставляет CurrentUser и роли для application use cases

infrastructure
  ├── владеет Station, Operator и Train
  ├── управляет прямыми направлениями поездов
  └── регистрирует прибытие поезда оператором конечной станции

routing
  └── использует read-порт TrainRepository для проверки прямых направлений

cargo
  ├── владеет Cargo и переходами CargoStatus
  ├── использует identity для проверки отправителя, получателя и роли оператора
  ├── использует infrastructure для станций, поездов и привязки оператора
  └── использует routing для проверки прямых направлений и поиска поездов
```

Отслеживание остаётся отдельной frontend-функцией, но backend use case
`TrackCargo` принадлежит контексту cargo. Прямой импорт ORM-моделей между
модулями запрещён. Если cargo нужен объект из другого контекста, он получает
его через порт, идентификатор или небольшой DTO. Это сохраняет возможность
заменить БД и HTTP-слой без изменения доменных правил.
