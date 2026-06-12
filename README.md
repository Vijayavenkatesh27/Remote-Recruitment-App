# RemoteRecruit Pro

RemoteRecruit Pro is a modern SwiftUI iOS application for browsing available jobs, searching by title/company, viewing job details, and saving jobs for offline review. It was built for the "RemoteRecruit - Job Browser App" iOS Engineer technical examination.

## Architecture

- SwiftUI UI with MVVM view models.
- Protocol-based networking, repositories, saved-job storage, and search-history storage.
- Constructor injection plus an environment `AppContainer`.
- Async/await networking through `URLSession`.
- SwiftData persistence for bookmarked jobs and offline saved-job access.
- Task-based search debouncing for responsive real-time job search.
- Explicit loading, empty, success, and error states.

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

## Setup

1. Open `RemoteRecruit.xcodeproj` in Xcode.
2. Select an iPhone simulator.
3. Build and run the `RemoteRecruit` target.

No API key is required for Arbeitnow.

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

## Assumptions and Limitations

- Arbeitnow pagination is supported through the `page` query item.
- Salary and skill extraction are local heuristics because the API does not always return normalized fields.
- The app avoids claiming real AI decisions; internal ranking uses explainable keyword-based signals.
- Tests are included in the `RemoteRecruitTests` target for execution from Xcode or CI. Use Xcode's coverage report to confirm the requested 70% business-logic coverage before submission.
