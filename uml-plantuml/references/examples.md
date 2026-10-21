# Примеры (проверены рендером, PlantUML 1.2025.4)

## Диаграмма вариантов использования «Железная дорога»

Актёр-родитель «Участник системы» держит вход/выход, без `include`. `left to right direction`, плавные линии (без `linetype`).

```plantuml
@startuml
!theme plain
title Диаграмма вариантов использования системы «Железная дорога»
left to right direction
skinparam nodesep 50
skinparam ranksep 70
skinparam shadowing false
skinparam roundcorner 8
skinparam dpi 150
skinparam defaultFontName DejaVu Sans

actor "Участник\nсистемы" as U
actor "Администратор" as A
actor "Оператор\nна станции" as O
actor "Пользователь" as P

A -up-|> U
O -up-|> U
P -up-|> U

rectangle "Система «Железная дорога»" {
  rectangle "Общий доступ\n\n" as G0 {
    usecase "Войти в систему" as L1
    usecase "Выйти из системы" as L2
  }
  rectangle "Управление\nинфраструктурой\n\n" as G1 {
    usecase "Управлять\nстанциями" as A1
    usecase "Управлять\nоператорами" as A2
    usecase "Управлять\nпоездами" as A3
  }
  rectangle "Обработка грузов\nна станции\n\n" as G2 {
    usecase "Принять груз" as O1
    usecase "Распределить груз\nпо поездам" as O2
    usecase "Получить груз" as O3
  }
  rectangle "Работа пользователя\nс грузом\n\n" as G3 {
    usecase "Отправить груз" as P1
    usecase "Отследить груз" as P2
  }
}

U -down-> L1
U -down-> L2
A -down-> A1
A -down-> A2
A -down-> A3
O -down-> O1
O -down-> O2
O -down-> O3
P -down-> P1
P -down-> P2
@enduml
```

## Диаграмма классов «Железная дорога»

Иерархия сверху, `Station` в центре, направления заданы вручную, без пакетов, enum сбоку.

```plantuml
@startuml
!theme plain
title Диаграмма классов системы «Железная дорога»
skinparam nodesep 70
skinparam ranksep 80
skinparam shadowing false
skinparam roundcorner 8
skinparam dpi 150
skinparam defaultFontName DejaVu Sans
hide empty members

abstract class User {
  -identifier : String
  -password : String
  -name : String
  +login(identifier, password) : boolean
  +logout() : void
}

class Administrator {
  +addStation(station) : void
  +removeStation(station) : void
  +addOperator(operator) : void
  +removeOperator(operator) : void
  +addTrain(train) : void
  +removeTrain(train) : void
}

class Operator {
  +receiveCargo(cargo) : void
  +assignCargo(cargo, train) : void
  +collectCargo(cargoId) : void
}

class Station {
  -code : String
  -name : String
  +addOperator(operator) : void
  +removeOperator(operator) : void
}

class Train {
  -number : String
  -status : TrainStatus
  +goesTo(station) : boolean
  +addStation(station) : void
}

class Route {
  +contains(station) : boolean
  +nextStation(station) : Station
}

class Cargo {
  -identifier : String
  -description : String
  -weight : Decimal
  -status : CargoStatus
  +accept() : void
  +dispatch(train) : void
  +collect() : void
}

enum TrainStatus {
  READY
  IN_TRANSIT
  ARRIVED
}

enum CargoStatus {
  AWAITING_ACCEPTANCE
  ACCEPTED_AT_STATION
  IN_TRANSIT
  COLLECTED
}

' --- иерархия пользователей
Administrator -up-|> User
Operator -up-|> User

' --- Administrator управляет
Administrator -right..> Operator : управляет
Administrator -down..> Station : управляет
Administrator ..> Train : управляет

' --- Operator
Operator -down..> Cargo : обрабатывает
Station "1" o-up- "0..*" Operator : нанимает

' --- груз
User "1" -- "0..*" Cargo : отправитель
Cargo "0..*" -left-> "1" Station : станция отправления
Cargo "0..*" -left-> "1" Station : станция назначения
Cargo "0..*" -down-> "0..1" Train : назначен на

' --- поезд и маршрут
Train "1" *-left- "1" Route : имеет
Route "1" o-up- "2..*" Station : проходит через

' --- перечисления
Cargo -right..> CargoStatus
Train -right..> TrainStatus
@enduml
```
