# Architecture & Design Patterns — Interview Prep

Reference doc for talking through this project's architecture, the design patterns used, why each was chosen, and likely interview questions with answers.

## 1. Overall architecture: MVVM + Repository, layered

```
App        composition root (AppContainer) + entry point
Features   SwiftUI views + @Observable ViewModels
Domain     plain Swift models shared by UI and data layer
Data       repositories, remote data sources, DTOs, mappers, SwiftData cache
Core       networking primitives (HTTPClient, Endpoint, NetworkError, NetworkLogger)
UI         shared, feature-agnostic views
```

**Why:** Keeps UI code, business rules, and data access independently testable and replaceable. `Domain` depends on nothing else in the app — it's the shared vocabulary — so `Features` never needs to know how data is fetched or cached, and `Data` never needs to know how it's displayed.

**Dependency rule:** arrows point inward. `Features` depends on `Domain` and on repository *protocols* (not concrete `Data` types). `Data` depends on `Domain` to know what to map into. Nothing in `Domain` imports `Features` or `Data`.

**Where:** folder structure itself — [Rick&Morty_app/](Rick&Morty_app).

---

## 2. Design patterns used

### MVVM (Model-View-ViewModel)
- **Where:** [CharactersListViewModel.swift](Rick&Morty_app/Features/CharactersList/CharactersListViewModel.swift), [CharacterDetailsViewModel.swift](Rick&Morty_app/Features/CharacterDetails/CharacterDetailsViewModel.swift)
- **Why:** SwiftUI views stay declarative and dumb — they render whatever state the ViewModel publishes and forward user intent (`onAppear`, `retry`, `loadNextPageIfNeeded`) back to it. All business logic (pagination, debounce, sorting, error mapping) lives in the ViewModel, so it's unit-testable without instantiating a single `View`.
- **Mechanism:** `@Observable` macro (Observation framework) + `@State` in the view owning it. No Combine, no delegates.

### Repository pattern
- **Where:** [CharacterRepositoryProtocol.swift](Rick&Morty_app/Data/Repositories/CharacterRepositoryProtocol.swift) / [CharacterRepository.swift](Rick&Morty_app/Data/Repositories/CharacterRepository.swift), same for Episode.
- **Why:** ViewModels ask for `Page<Character>` without knowing or caring whether it came from the network or the cache. The repository owns that policy (remote-first, write-through cache, cache fallback on failure) in one place instead of scattering `if offline` checks through the UI layer.

### Dependency Injection (constructor injection, no framework)
- **Where:** [AppContainer.swift](Rick&Morty_app/App/AppContainer.swift) is the single composition root; it builds the `ModelContainer`, `LocalStore`, `URLSessionHTTPClient`, and both repositories once, then hands them down through initializers.
- **Why:** Every dependency is a protocol (`CharacterRepositoryProtocol`, `HTTPClient`, `CharacterRemoteDataSource`, ...), so tests substitute mocks with a plain initializer call — no framework, no service locator, no runtime magic. A DI container (Swinject, Factory, etc.) would add a dependency for something four `init` calls already solve at this app's size.

### Dependency Inversion / Protocol-oriented abstractions
- **Where:** `HTTPClient` (protocol) / `URLSessionHTTPClient` (impl); `CharacterRemoteDataSource` / `DefaultCharacterRemoteDataSource`; both repository protocols.
- **Why:** High-level modules (ViewModels, repositories) depend on abstractions, not on `URLSession` or SwiftData directly. This is what makes the actor-based mocks in `Rick&Morty_appTests` possible without touching the network or disk.

### Mapper pattern (DTO ↔ Domain boundary)
- **Where:** [CharacterMapper.swift](Rick&Morty_app/Data/Mappers/CharacterMapper.swift), `EpisodeMapper`, `CharacterCacheMapper`, `EpisodeCacheMapper`.
- **Why:** `CharacterDTO` mirrors the API's wire format exactly (raw strings for `status`/`gender`, since the API can change or add values). `Character` (domain) has typed enums with an `.unknown` fallback. The mapper is the one place that translates between them — a new or unexpected API value degrades to `.unknown` instead of crashing decode.

### State machine (explicit state, not booleans)
- **Where:** `CharactersListViewModel.State` (`idle`/`loading`/`loaded`/`empty`/`error`), `CharacterDetailsViewModel.EpisodesState`.
- **Why:** A `Bool` per condition (`isLoading`, `hasError`, `isEmpty`, ...) allows impossible combinations (loading *and* error at once). An enum makes the valid states exhaustive and the view's `switch` exhaustive too — the compiler catches a missing case. Overlay conditions that legitimately coexist with a loaded state (`isLoadingNextPage`, `isRefreshing`) are kept as separate flags on purpose, since a page-2 spinner shouldn't blank the whole screen the way the initial `.loading` state does.

### Strategy pattern
- **Where:** [CharacterSortOption.swift](Rick&Morty_app/Features/CharactersList/CharacterSortOption.swift) — `.none` / `.nameAscending` / `.nameDescending`, each implementing `apply(to:)`.
- **Why:** The ViewModel calls `sortOption.apply(to: fetched)` without knowing which comparison runs. Adding a new sort order means adding a case, not touching the ViewModel. An enum-with-methods is the idiomatic Swift shape for Strategy when the set of strategies is closed and small — no need for a protocol + one struct per strategy.

### Derived state / single source of truth
- **Where:** `CharactersListViewModel.fetched` (raw, unsorted) vs. `characters` (published, sorted projection), recomputed by `applySorting()`.
- **Why:** Sorting and pagination are orthogonal. `fetched` is the only place new pages get appended; `characters` is never mutated directly, only re-derived. This avoids bugs where sorting and appending disagree about which array is current.

### Property observers as lightweight reactive bindings
- **Where:** `searchText`, `statusFilter`, `sortOption` all use `didSet` in `CharactersListViewModel`.
- **Why:** Changing a filter/sort input should automatically reload or re-derive the list — `didSet` plus a `guard oldValue != newValue` (idempotency guard against redundant work) gives that without a Combine pipeline or manual "on change" plumbing. `@Observable` then propagates the resulting `characters`/`state` change to the view.

### Debounce (via structured concurrency, not Combine)
- **Where:** `CharactersListViewModel.debounceSearch()` — a `Task.sleep(for: .milliseconds(400))` before reloading, cancelled/superseded implicitly by re-assigning `searchTask`... (see actual field) — prevents one network request per keystroke.
- **Why:** Search-as-you-type without debounce would fire a request per character. `Task { try? await Task.sleep(...) }` is the async/await-native way to do this without importing Combine for one operator.

### Cache-aside / write-through caching, with graceful degradation
- **Where:** `CharacterRepository.fetchCharacters`, `EpisodeRepository.fetchEpisodes`, backed by `LocalStore` (`@ModelActor` over SwiftData).
- **Why:** Remote-first: a successful fetch is returned immediately and cached in the background (cache write failure is swallowed — `try?` — since it must never fail an otherwise-successful response). On network failure, the repository serves whatever matches the current filter from the cache instead of surfacing an error, iff the cache actually has something. A cache-served page reports `hasNextPage = false` — pagination can't be verified without the network, so this is a documented, deliberate assumption rather than a bug.
- **Upsert via unique constraint:** `CachedCharacter`/`CachedEpisode` use `@Attribute(.unique)` on `id`. Re-inserting an existing id merges into the existing row automatically — no manual "fetch, check if exists, update-or-insert" branch needed.

### Actor isolation for shared mutable state
- **Where:** `LocalStore` is `@ModelActor actor` — every method hops onto its own isolated executor, so concurrent repository calls can't race on the `ModelContext`. ViewModels are `@MainActor` so all `@Observable` state mutation happens on the main thread, which SwiftUI requires.
- **Why:** Swift 6 strict concurrency won't compile a data race silently; actors are the language-level answer to "this mutable state is touched from multiple tasks."

### Facade (thin one)
- **Where:** `HTTPClient.send<E: Endpoint, T: Decodable & Sendable>(_:)` hides request building, logging, transport, HTTP-status mapping, and decoding behind one call.
- **Why:** Callers (`DefaultCharacterRemoteDataSource`, `DefaultEpisodeRemoteDataSource`) just say "send this endpoint, give me this type back."

---

## 3. Likely interview questions (with answers)

**Q: Why MVVM instead of a Redux-style / TCA unidirectional store?**
A: At this app's size (two screens, no deeply nested shared state), MVVM with `@Observable` gives the same testability and separation of concerns with far less ceremony. TCA's reducer/action/store machinery pays off once state sharing across many features gets complex — it would be over-engineering here.

**Q: Why Repository pattern instead of calling the network layer directly from the ViewModel?**
A: The ViewModel would otherwise need to know about offline fallback, cache writes, and 404-as-empty-result semantics. The repository is the one place that owns "where does this data actually come from," so that policy is testable in isolation and the ViewModel just asks for a `Page<Character>`.

**Q: Why no dependency injection framework?**
A: Every dependency is a protocol and every type takes its dependencies through `init`. `AppContainer` is the one place that wires concrete types together. A framework (Swinject, Factory) would add indirection and a learning curve for a graph of about six objects — not justified at this scale, though the protocol boundaries mean adopting one later wouldn't require restructuring anything.

**Q: How is this testable? What's mocked?**
A: Everything the ViewModels and repositories depend on is a protocol: `CharacterRepositoryProtocol`, `EpisodeRepositoryProtocol`, `CharacterRemoteDataSource`, `EpisodeRemoteDataSource`, `HTTPClient`. Tests use actor-based mocks (Sendable by construction) that record calls and return canned results — see `Rick&Morty_appTests/Mocks/`. `URLSessionHTTPClient` itself is tested against a stubbed `URLProtocol`, and repository tests use a real `LocalStore` backed by an in-memory `ModelContainer` rather than mocking SwiftData.

**Q: Why SwiftData instead of Core Data?**
A: SwiftData is Core Data's modern Swift-native successor — `@Model` macros instead of `.xcdatamodeld` files, `#Predicate` instead of `NSPredicate` strings, and first-class actor support (`@ModelActor`) for concurrency safety. Since the project targets iOS 18+/Swift 6 with no legacy Core Data investment, there's no reason to pick the older API.

**Q: Why does a cache-served page report `hasNextPage = false`?**
A: The cache only stores what's already been fetched — it can't tell you whether the API has more pages beyond that without asking the API. Rather than guess, the repository is explicit: cache fallback is a degraded, read-only view of what's known, not a full offline-pagination feature. That's called out in the README as an assumption.

**Q: Why treat HTTP 404 as an empty result instead of an error?**
A: The Rick & Morty API returns 404 specifically when a character search/filter matches nothing — that's a valid "zero results" response, not a failure. Mapping it to an empty `Page` keeps the UI's empty state (not its error state) responsible for communicating "no matches," which is the correct UX for a search with no hits.

**Q: How do you avoid a race condition between typing in search and a slow network response?**
A: Two guards: (1) the 400ms debounce coalesces rapid keystrokes into one request; (2) `removeDuplicates`/`seenIDs` and the fact that each reload resets `page`/`fetched` mean a stale in-flight request that finally resolves can't corrupt state that's already moved on to a newer filter — though a stricter implementation would also cancel the superseded `Task` explicitly rather than relying on state getting overwritten.

**Q: Walk me through what happens when the app has no internet connection.**
A: `URLSessionHTTPClient` throws a mapped `NetworkError` (e.g. `.noInternetConnection`). The repository catches it, queries `LocalStore` for whatever matches the current filter, and returns that with `hasNextPage = false` if the cache has anything; if the cache is empty too, it rethrows and the ViewModel's `.error` state is shown with a Retry button.

**Q: Why does `CharacterDTO` keep raw strings for `status`/`gender` instead of decoding straight to the domain enums?**
A: If the API ever adds a new status/gender value, decoding directly to a strict enum would throw a `DecodingError` and the whole response would fail to parse. Keeping the DTO's fields as `String` and mapping to the domain enum with an `.unknown` fallback means an unrecognized value degrades gracefully instead of breaking the feature.

**Q: How does image loading/caching work?**
A: Nuke/NukeUI's `LazyImage`, wrapped in `RemoteImageView`. Nuke handles async loading plus both memory and disk caching itself — not reimplemented here — with a placeholder while loading and a fallback icon on failure.

**Q: Why is `AppContainer` not `@Observable`/a singleton?**
A: It's built exactly once, in `RickAndMortyApp`'s `@State`, and handed down through `init` — there's no need for it to publish changes (its properties are `let`), and a singleton (`AppContainer.shared`) would make it global mutable-ish state and harder to substitute in tests/previews. The second `init(characterRepository:episodeRepository:)` overload exists specifically for that substitution.

**Q: How would you scale this architecture to 10 more screens?**
A: The layering already supports it — each new screen is a new folder under `Features/` with its own View + ViewModel, reusing existing repositories/`Domain` models where the data overlaps, and adding new repository protocols where it doesn't. The place that would need rethinking first is `AppContainer` growing into a long list of `let` properties — at that point, breaking it into per-feature factory methods or lazy properties would keep it from becoming a god object.

**Q: What Swift 6 concurrency features are load-bearing here, and why?**
A: `Sendable` on every model/DTO (required because they cross actor boundaries: background decode → `@ModelActor` cache → `@MainActor` ViewModel), `@MainActor` explicitly on ViewModels, and `@ModelActor` on `LocalStore` for SwiftData's `ModelContext` isolation. The project deliberately does *not* rely on Xcode 16's `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` template default, because that setting also isolates plain structs/DTOs to the main actor, which broke `Decodable & Sendable` conformance for types decoded on a background task — explicit per-type isolation was chosen over an implicit project-wide default.
