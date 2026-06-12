# RemoteRecruit Pro

RemoteRecruit Pro is a modern SwiftUI iOS application for browsing available jobs, searching by title/company, viewing job details, and saving jobs for offline review. It was built for the "RemoteRecruit - Job Browser App" iOS Engineer technical examination.

## Setup Instructions

1. Clone the repository.
2. Open `RemoteRecruit.xcodeproj` in Xcode.
3. Select an iPhone simulator.
4. Build and run the `RemoteRecruit` target.

No API key is required because the app uses the free Arbeitnow Jobs API.

## Architecture Explanation

- SwiftUI UI with MVVM view models.
- Protocol-based networking, repositories, saved-job storage, and search-history storage.
- Constructor injection plus an environment `AppContainer`.
- Async/await networking through `URLSession`.
- SwiftData persistence for bookmarked jobs and offline saved-job access.
- Task-based search debouncing for responsive real-time job search.
- Explicit loading, empty, success, and error states.

### Folder Structure

- `App`: app entry point and dependency container.
- `Models`: app domain models and state enums.
- `Views`: SwiftUI screens.
- `ViewModels`: MVVM presentation and business state logic.
- `Components`: reusable UI components.
- `Network`: endpoint, API client, DTO parsing, and network errors.
- `Repositories`: data access, search history, saved jobs, and API fallback coordination.
- `Services`: fallback JSON provider.
- `Utilities`: search matching, salary estimation, haptics, previews, and theme helpers.
- `Resources`: bundled fallback job data.
- `RemoteRecruitTests`: XCTest coverage for business logic, repositories, and view models.

## Design Decisions

- Job discovery prioritizes technology roles with deterministic keyword ranking; the UI focuses on real job details rather than artificial scores.
- The free Arbeitnow API does not provide a normalized salary field, but the exam requires salary range. RemoteRecruit Pro therefore always displays a salary range using bundled fallback salary data or a clearly documented local salary estimate.
- Saved jobs are persisted with SwiftData; recent search terms are stored in `UserDefaults`.
- A bundled `fallbackJobs.json` file keeps the app functional if the API request fails.
- Filters are local and deterministic: All, Remote, Hybrid, Full-Time, Part-Time, Contract, and Tech.

## API

Primary endpoint:

```text
https://www.arbeitnow.com/api/job-board-api?page={page}
```

The network layer is split into `Endpoint`, `APIClientProtocol`, `URLSessionAPIClient`, DTO parsing, and repository mapping.

## Requirement Coverage

- Job listing: title, company, location, salary range, employment type, seniority/work-style chips, and save actions.
- Search: title, company, location, and keyword search with recent history.
- Details: description, company, salary range, location, skills, original apply URL.
- State handling: loading skeletons, empty states, retryable error states.
- Data source: free public API plus local JSON fallback.
- Testing: XCTest target with unit tests for ranking, salary logic, filters, search history, and repository fallback behavior.

## Testing Strategy

The code is structured for XCTest with mock `APIClientProtocol`, mock repositories, and isolated utilities such as `MatchScorer`, `SalaryInsight`, `JobFilter`, and `SkillExtractor`. The included tests target the business logic that matters most for the exam: repositories, fallback behavior, filters, salary ranges, search history, and deterministic ranking.

Verified command:

```sh
xcodebuild -scheme RemoteRecruit -project RemoteRecruit.xcodeproj -destination 'generic/platform=iOS Simulator' build
```

Verified tests:

```sh
xcodebuild -scheme RemoteRecruit -project RemoteRecruit.xcodeproj -destination 'platform=iOS Simulator,name=iphone 17 pro,OS=26.0' test
```

## Assumptions Made

- Arbeitnow pagination is supported through the `page` query item.
- Arbeitnow does not provide normalized salary data for every job, so salary ranges are displayed using bundled fallback data or a local salary estimate.
- Skill extraction is heuristic-based because public job descriptions are unstructured.
- Saved jobs are stored locally with SwiftData; if persistent storage cannot be opened, the app falls back to an in-memory store instead of crashing.
- The app avoids claiming real AI decisions; internal ranking uses explainable keyword-based signals.
- The 70% coverage target is interpreted as business-logic coverage, not total app coverage including SwiftUI view layout code.
