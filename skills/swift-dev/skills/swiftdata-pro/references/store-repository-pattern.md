# SwiftData — Store / Repository Pattern (Agent Reference)

This document defines the preferred SwiftData data-layer architecture for this
project. Agents implementing or modifying persistence code MUST follow these
patterns. The SwiftData layer is kept separate from SwiftUI. Two patterns are
provided and are meant to be combined: **Repository** (explicit, injectable) and
**Active Record** (models persist themselves, delegating to a shared repository).

## Rules for agents

- Keep all persistence logic in this layer; SwiftUI views never touch `ModelContext` directly.
- Reuse the existing `Repository` protocol and its default extension — do NOT reimplement CRUD per model.
- All data-layer types are `@MainActor`. Heavy work should be offloaded with async/await, but the default is main-actor.
- Throw `DataLayerError` cases only. Do not invent new error types without updating this enum.
- For dependency-injected/testable code use `StoreRepository`. For terse model-centric code use `ActiveRecord`.

## Components

| Component | Responsibility |
|---|---|
| `DataLayerError` | Error enum for the data layer (add/fetch/delete/save/notFound/invalidType). |
| `PersistenceStack` | Configures and owns the `ModelContainer` + `ModelContext`. |
| `Repository` (protocol) | CRUD blueprint with a default implementation via extension. |
| `StoreRepository<Model>` | Generic repository with an injected stack (dependency injection, testable). |
| `DataBase` | Singleton holding one shared `PersistenceStack` (used by Active Record). |
| `GenericRepository<Model>` | Repository that uses `DataBase.shared.persistenceStack`. |
| `ActiveRecord` (protocol) | Lets a model save/delete/fetch itself, delegating to a repository. |

---

## 1. Errors — `DataLayerError`

```swift
import Foundation

/// Errors specific to the `StoreRepository`.
public enum DataLayerError: Error, LocalizedError {
    case addFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
    case saveFailed(Error)
    case modelNotFound
    case invalidModelType

    public var errorDescription: String? {
        switch self {
        case .addFailed(let error):
            return "Failed to add the model: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch models: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete the model: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "Failed to save the context: \(error.localizedDescription)"
        case .modelNotFound:
            return "Model not found."
        case .invalidModelType:
            return "Invalid model type."
        }
    }
}
```

Granular cases + `LocalizedError` give readable messages and fine-grained recovery.

---

## 2. `PersistenceStack`

Encapsulates creation of the `ModelContainer` and `ModelContext`. If SwiftData's
initialization API changes, only this file needs to change.

```swift
import SwiftData

/// Persistence stack responsible for configuring and managing the model container and context.
@MainActor
public class PersistenceStack {
    public let container: ModelContainer?
    public let context: ModelContext?
    private let modelTypes: [any PersistentModel.Type]

    /// - Parameters:
    ///   - modelTypes: model types to manage.
    ///   - isMemoryOnly: store in memory only (useful for tests/temporary data).
    public init(modelTypes: [any PersistentModel.Type], isMemoryOnly: Bool) throws {
        self.modelTypes = modelTypes
        let schema = Schema(modelTypes)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isMemoryOnly)
        do {
            self.container = try ModelContainer(for: schema, configurations: [configuration])
            self.context = container?.mainContext
        } catch {
            throw DataLayerError.addFailed(error)
        }
    }
}
```

The `isMemoryOnly` flag switches between on-disk (production) and in-memory (tests).

---

## 3. `Repository` protocol + default CRUD extension

Both Repository and Active Record share the same CRUD, so the protocol is the
single blueprint and the extension provides the default behavior. Do not
duplicate this logic per model.

```swift
/// Protocol defining basic operations for data repository.
@MainActor
public protocol Repository {
    associatedtype Model: PersistentModel

    var persistenceStack: PersistenceStack { get }

    func add(_ model: Model) throws
    func fetchAll() throws -> Set<Model>
    func fetch(byID id: Model.ID) throws -> Model?
    func saveAll(_ models: [Model]) throws
    func delete(_ model: Model) throws
    func deleteAll(_ modelType: Model.Type) throws
}
```

```swift
extension Repository {
    public func add(_ model: Model) throws {
        guard let context = persistenceStack.context else {
            throw DataLayerError.invalidModelType
        }
        context.insert(model)
        do {
            try context.save()
        } catch {
            throw DataLayerError.addFailed(error)
        }
    }

    public func fetchAll() throws -> Set<Model> {
        guard let context = persistenceStack.context else {
            throw DataLayerError.invalidModelType
        }
        do {
            let results = try context.fetch(FetchDescriptor<Model>())
            return Set(results)
        } catch {
            throw DataLayerError.fetchFailed(error)
        }
    }

    public func fetch(byID id: Model.ID) throws -> Model? {
        let allModels = try fetchAll()
        return allModels.first { $0.id == id }
    }

    public func saveAll(_ models: [Model]) throws {
        for model in models {
            do {
                try add(model)
            } catch {
                throw DataLayerError.saveFailed(error)
            }
        }
    }

    public func delete(_ model: Model) throws {
        guard let context = persistenceStack.context else {
            throw DataLayerError.invalidModelType
        }
        context.delete(model)
        do {
            try context.save()
        } catch {
            throw DataLayerError.deleteFailed(error)
        }
    }

    public func deleteAll(_ modelType: Model.Type) throws {
        guard let context = persistenceStack.context else {
            throw DataLayerError.invalidModelType
        }
        do {
            let fetchDescriptor = FetchDescriptor<Model>()
            let results = try context.fetch(fetchDescriptor)
            for model in results {
                context.delete(model)
            }
            try context.save()
        } catch {
            throw DataLayerError.deleteFailed(error)
        }
    }
}
```

### CRUD method notes

- `add` — validates the context, inserts, then saves; save failure → `addFailed`.
- `fetchAll` — `FetchDescriptor` retrieves all instances; failure → `fetchFailed`. Returns a `Set` (no duplicates).
- `fetch(byID:)` — fetches all, then filters by `id`.
- `saveAll` — iterates and `add`s each; propagates failure as `saveFailed`.
- `delete` — removes from context and saves; failure → `deleteFailed`.
- `deleteAll` — fetches all of the type, deletes each, commits once.

---

## 4. `StoreRepository` (dependency injection)

Generic repository that receives the stack via init — easy to mock in tests.
Use this when you want explicit control and injectability.

```swift
import SwiftData

/// Repository responsible for managing persistent models storage.
@MainActor
open class StoreRepository<Model: PersistentModel>: Repository {
    public let persistenceStack: PersistenceStack

    public init(stack: PersistenceStack) throws {
        self.persistenceStack = stack
    }
}
```

### Usage with Repository (ViewModel injects the stack)

```swift
@Model
final class Note {
    var title: String
    var content: String
    var creationDate: Date

    init(title: String, content: String, creationDate: Date = Date()) {
        self.title = title
        self.content = content
        self.creationDate = creationDate
    }
}

@MainActor
@Observable
class ViewModel {
    var notes: [Note] = []
    var noteRepository: StoreRepository<Note>?

    init() {
        do {
            self.noteRepository = try .init(stack: .init(modelTypes: [Note.self], isMemoryOnly: false))
            update()
        } catch {
            print(error)
        }
    }

    func update() {
        guard let noteRepository else { return }
        do {
            self.notes = Array(try noteRepository.fetchAll())
        } catch { print(error) }
    }

    func addNote() {
        guard let noteRepository else { return }
        let note = Note(title: "New Note", content: "New Content")
        do {
            try noteRepository.add(note)
            update()
        } catch { print(error) }
    }

    func deleteNote(at offsets: IndexSet) {
        offsets.forEach {
            do { try noteRepository?.delete(self.notes[$0]) }
            catch { print(error) }
        }
    }
}
```

```swift
struct ContentView: View {
    var viewModel: ViewModel = .init()

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.notes) { note in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title).font(.headline)
                    }
                }
                .onDelete(perform: viewModel.deleteNote)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: viewModel.addNote) {
                        Label("New note", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Notes")
        }
    }
}
```

---

## 5. Active Record (shared stack via singleton)

When you want the terse API (`note.save()`, `Note.fetchAll()`), use a shared
stack and let the model persist itself. Internally it delegates to
`GenericRepository`, so persistence logic stays centralized.

```swift
@MainActor
class DataBase {
    /// Shared singleton — single, consistent persistence configuration.
    static var shared: DataBase = .init()
    var persistenceStack: PersistenceStack

    private init() {
        // Register EVERY model used with Active Record here.
        self.persistenceStack = try! PersistenceStack(
            modelTypes: [Note.self, Tag.self],
            isMemoryOnly: false
        )
    }
}

/// Repository that uses the shared stack from the DataBase singleton.
class GenericRepository<Model: PersistentModel>: Repository {
    var persistenceStack: PersistenceStack = DataBase.shared.persistenceStack
}

@MainActor
protocol ActiveRecord: PersistentModel {
    func save() throws
    func delete() throws
    static func fetchAll() throws -> Set<Self>
    static func find(byID id: Self.ID) throws -> Self?
}

extension ActiveRecord {
    func save() throws {
        let repository = GenericRepository<Self>()
        try repository.add(self)
    }

    func delete() throws {
        let repository = GenericRepository<Self>()
        if let model = try? repository.fetch(byID: self.id) {
            try repository.delete(model)
        }
    }

    static func fetchAll() throws -> Set<Self> {
        try GenericRepository<Self>().fetchAll()
    }

    static func find(byID id: Self.ID) throws -> Self? {
        try GenericRepository<Self>().fetch(byID: id)
    }
}
```

### Usage with Active Record (minimal ViewModel)

```swift
@MainActor
@Observable
class ViewModel {
    var notes: [Note] = []

    init() { update() }

    func update() {
        do { self.notes = Array(try Note.fetchAll()) }
        catch { print(error) }
    }

    func addNote() {
        let note = Note(title: "New Note", content: "New Content")
        do { try note.save(); update() }
        catch { print(error) }
    }

    func deleteNote(at offsets: IndexSet) {
        offsets.forEach {
            do { try self.notes[$0].delete() }
            catch { print(error) }
        }
    }
}
```

To use Active Record, a model MUST conform to `ActiveRecord` and be registered in
the `DataBase` singleton's `modelTypes`.

---

## When to use which

- **Repository / `StoreRepository`** — when you want to inject the stack, keep
  business logic strictly separate from persistence, and mock in tests. More ceremony.
- **Active Record** — when you want short, direct code (`model.save()`), accepting
  that data and behavior are coupled. Good for small/medium projects.
- **Both together (preferred)** — `ActiveRecord` delegates to `GenericRepository`,
  giving the convenient API on top of one centralized base.

## Considerations

- All data-layer types are `@MainActor` (safe for SwiftUI UI updates). For heavy
  work, offload to background queues with async/await.
- `DataLayerError` centralizes and standardizes error handling across the layer.
- Future extensions without major refactoring: caching (a `DataStore` component),
  offline synchronization, change observers/event delegates.

## Trade-offs

- **Boilerplate** — explicit setup and error handling add lines; the cost buys robustness.
- **Coupling (Active Record)** — couples persistence with the model; for very
  complex apps prefer the Repository separation or add a service layer.
- **Performance** — the extra abstraction layers add negligible overhead in
  practice versus the maintainability/testability gains.
