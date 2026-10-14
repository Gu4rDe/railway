# Шаблоны PlantUML по типам диаграмм

Содержание: [Классы](#классы) · [Последовательность](#последовательность) · [Варианты использования](#варианты-использования) · [Активность](#активность) · [Состояния](#состояния) · [Компоненты](#компоненты) · [Развёртывание](#развёртывание) · [ER-диаграмма](#er-диаграмма) · [Mermaid](#mermaid)

Каждый шаблон — готовая «шапка» плюс каркас. Копируй шапку целиком, затем подставляй содержимое. Для чёрно-белой печати добавь `!theme plain` сразу после `@startuml`.

---

## Классы

```plantuml
@startuml
skinparam linetype ortho
skinparam nodesep 70
skinparam ranksep 70
skinparam shadowing false
skinparam roundcorner 8
skinparam classAttributeIconSize 0
skinparam dpi 150
hide empty members

package "Модель" {
  abstract class Account {
    -id : int
    -balance : double
    +deposit(amount : double) : void
    +withdraw(amount : double) : boolean
  }
  class SavingsAccount {
    -rate : double
  }
  class Customer {
    -name : String
  }
}

interface Auditable {
  +audit() : void
}

Account <|-- SavingsAccount
Account ..|> Auditable
Customer "1" *-- "0..*" Account : владеет
@enduml
```

Заметки: главные классы расставляй вверху, зависимые ниже. Для управления положением используй `-down->`, `-right->`.

---

## Последовательность

```plantuml
@startuml
skinparam shadowing false
skinparam dpi 150
skinparam sequenceMessageAlign center
skinparam responseMessageBelowArrow true
skinparam maxMessageSize 150
autonumber

actor Пользователь as U
participant "Веб-клиент" as C
participant "Сервер" as S
database "БД" as DB

U -> C : Ввод логина и пароля
activate C
C -> S : POST /login
activate S
S -> DB : Найти пользователя
activate DB
DB --> S : Запись пользователя
deactivate DB
alt пароль верный
  S --> C : 200 OK + токен
else пароль неверный
  S --> C : 401 Unauthorized
end
deactivate S
C --> U : Результат входа
deactivate C
@enduml
```

Заметки: не больше 4–6 участников. Синхронный вызов — `->`, ответ — `-->`, асинхронный — `->>`. Условия — `alt/else/end`, циклы — `loop`, необязательные блоки — `opt`.

---

## Варианты использования

```plantuml
@startuml
skinparam shadowing false
skinparam dpi 150
skinparam packageStyle rectangle
left to right direction

actor "Студент" as S
actor "Преподаватель" as T

rectangle "Система учёта" {
  usecase "Просмотр расписания" as UC1
  usecase "Сдача отчёта" as UC2
  usecase "Проверка отчёта" as UC3
  usecase "Авторизация" as UC4
}

S --> UC1
S --> UC2
T --> UC3
S --> UC4
T --> UC4
@enduml
```

Заметки: актёры всегда снаружи рамки системы, варианты использования внутри. Связи `<<include>>` (обязательная часть сценария) и `<<extend>>` (необязательное расширение) по умолчанию **не рисуй**: добавляй только если они прямо нужны по заданию или есть на образце. Лишние связи портят читаемость.

---

## Активность

Используй новый синтаксис (`start`, `:действие;`), а не устаревший.

```plantuml
@startuml
skinparam shadowing false
skinparam dpi 150
skinparam ActivityBackgroundColor #FFFFFF

|Пользователь|
start
:Открыть форму заказа;
:Заполнить данные;
|Система|
:Проверить данные;
if (Данные корректны?) then (да)
  :Создать заказ;
  fork
    :Отправить письмо;
  fork again
    :Списать со склада;
  end fork
else (нет)
  :Показать ошибку;
  stop
endif
|Пользователь|
:Получить подтверждение;
stop
@enduml
```

Заметки: дорожки (`|Название|`) группируют действия по исполнителям. Параллельные ветки — `fork / fork again / end fork`. Циклы — `while (условие?) is (да) ... endwhile (нет)`.

---

## Состояния

```plantuml
@startuml
skinparam shadowing false
skinparam dpi 150
skinparam roundcorner 12
hide empty description

[*] --> Новый
Новый --> Оплачен : оплата
Новый --> Отменён : отмена
Оплачен --> Отправлен : передан в доставку
Отправлен --> Доставлен : получен
Оплачен --> Отменён : возврат
Доставлен --> [*]
Отменён --> [*]
@enduml
```

Заметки: у каждого состояния должен быть путь входа и выхода. Охранные условия пиши в квадратных скобках: `: событие [условие] / действие`.

---

## Компоненты

```plantuml
@startuml
skinparam linetype ortho
skinparam shadowing false
skinparam dpi 150
skinparam componentStyle uml2
left to right direction

package "Клиент" {
  [Мобильное приложение] as App
}
package "Сервер" {
  [API-шлюз] as GW
  [Сервис авторизации] as Auth
  [Сервис файлов] as Files
}
database "PostgreSQL" as DB

App --> GW : HTTPS
GW --> Auth
GW --> Files
Auth --> DB
Files --> DB
@enduml
```

---

## Развёртывание

```plantuml
@startuml
skinparam shadowing false
skinparam dpi 150
skinparam linetype ortho

node "Устройство пользователя" {
  artifact "Android-приложение" as App
}
node "Сервер приложений" {
  artifact "backend.jar" as Back
}
node "Сервер БД" {
  database "PostgreSQL" as DB
}

App --> Back : HTTPS
Back --> DB : JDBC
@enduml
```

---

## ER-диаграмма

Для БД удобен нативный синтаксис PlantUML (IE-нотация):

```plantuml
@startuml
skinparam linetype ortho
skinparam shadowing false
skinparam dpi 150
hide circle

entity "Студент" as student {
  * id : int <<PK>>
  --
  * фио : varchar
  группа : varchar
}
entity "Отчёт" as report {
  * id : int <<PK>>
  --
  * student_id : int <<FK>>
  дата : date
}

student ||--o{ report
@enduml
```

Обозначения связей: `||` ровно один, `o|` ноль или один, `}o` ноль или много, `}|` один или много.

---

## Mermaid

Запасной вариант, когда нужен Markdown или GitHub.

Классы:

```mermaid
classDiagram
  class Account {
    -int id
    +deposit(double amount) void
  }
  Account <|-- SavingsAccount : наследование
  Customer "1" *-- "0..*" Account : композиция
  Account o-- Transaction : агрегация
  Account ..> Logger : зависимость
```

Последовательность:

```mermaid
sequenceDiagram
  autonumber
  actor U as Пользователь
  U->>S: запрос
  S-->>U: ответ
```

Связи в Mermaid: `<|--` наследование, `*--` композиция, `o--` агрегация, `-->` ассоциация, `..>` зависимость, `..|>` реализация.
