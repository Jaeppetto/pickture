# ADR-002: Clean Architecture + MVVM

## Status

Accepted

## Date

2026-02-15

## Context

Pickture needs a scalable architecture that supports:

- Testability: Domain logic must be testable without UI or framework dependencies.
- Separation of concerns: Photo library access, business logic, and UI must be independent.
- Swift Concurrency: Architecture must work naturally with async/await and actors.

### Options Considered

| Option                            | Pros                                     | Cons                                   |
| --------------------------------- | ---------------------------------------- | -------------------------------------- |
| **Clean Architecture + MVVM**     | Clear layer separation, testable, proven | More boilerplate                       |
| MV (Model-View)                   | Simple, less code                        | Business logic bleeds into views       |
| TCA (The Composable Architecture) | Excellent testability, unidirectional    | Heavy dependency, steep learning curve |
| VIPER                             | Very strict separation                   | Excessive boilerplate for this scale   |

## Decision

Adopt **Clean Architecture** with **MVVM** pattern:

```
Domain (Entities, Repository Protocols, Use Cases)
  ↑ depends on nothing
Data (Repository Implementations, DataSources, Mappers)
  ↑ depends on Domain
Presentation (Views, ViewModels)
  ↑ depends on Domain (via ViewModels)
```

### Key Patterns

- **@Observable macro** (iOS 17+) for ViewModels instead of ObservableObject.
- **Protocol-based Dependency Injection** via `AppContainer`.
- **Actor-based DataSources** for thread-safe data access.
- **Initializer injection** for all ViewModels.

## Consequences

- Domain layer has zero framework dependencies (only Foundation).
- Repository protocols are defined in Domain, implemented in Data.
- ViewModels are `@MainActor` and own business logic for their screens.
- `AppContainer` serves as the composition root for DI.
- All async operations use Swift Concurrency (async/await).
