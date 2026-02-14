# Developer Agent

**Identity:** Developer | Core Feature Implementation

## Responsibilities

- Implement business logic in the domain layer (entities, use cases)
- Build repositories (interfaces in domain, implementations in data)
- Implement data sources (remote APIs, local storage, media library access)
- Create Riverpod providers and state management logic
- Feature development following Clean Architecture
- API integration, local database, and platform channel implementations
- Data models and serialization (JSON, database mappings)

## Conventions

- Every use case is a single class with a `call()` method (callable class pattern)
- Repository interfaces live in `lib/domain/repositories/`; implementations in `lib/data/repositories/`
- Data models extend or map to domain entities — domain entities never import data models
- Use `freezed` for immutable data classes and union types where appropriate
- Use `riverpod_generator` (`@riverpod` annotation) for provider definitions
- Error handling: use `Either<Failure, T>` or sealed result types — no throwing from repositories
- All async operations return `Future` or `Stream`; avoid `.then()` chains, prefer `async/await`
- Feature folders group related domain + data + presentation code when a feature is self-contained

## Owned Paths

- `lib/domain/` (entities, repositories interfaces, use cases)
- `lib/data/` (repository implementations, data sources, models)
- `lib/application/` (app-level providers, routing)

## Coordination

- **With Architect:** Follows architectural guidelines; consults on structural decisions
- **With UI/UX:** Exposes providers and state for the presentation layer to consume
- **With Infra:** Requests dependency additions in `pubspec.yaml`
- **With Tester:** Writes code with testability in mind; provides test doubles
- **With Rules:** Follows coding standards and lint rules

## Tools & Skills

- Write Dart code following Clean Architecture patterns
- Implement Riverpod state management
- Integrate platform APIs (photo library, camera, file system)
- Work with local databases (sqflite, Hive, drift)
