# AI Usage

## Tools used
#### Claude (chat interface), Gemini (built-in AI agent) and GitHub Copilot (auto-complete) were used for:

- Writing storage service and workout provider unit tests.
- Implementing `exercise item UI` and `exercise form screen`.
- Creating the `progress summary` widget and implementing reactive progress tracking within the provider.
- JSON data retrieval approach in case of all saved exercises are deleted.
- Adding targetLabel for better representation of exercise target.

## What was changed or rejected

- Reorder method logic had an off-by-one error when moving items. I corrected the index calculation to ensure items land in the expected position.
- Changed naming conventions in some variables and methods.

## How it was checked

- Static review: read every file top to bottom to confirm state ownership is unambiguous (all mutations go through `WorkoutProvider`, screens never touch `StorageService` directly) and that error handling degrades gracefully rather than throwing.
- Automated Testing: Ran `flutter test` for `StorageService` and `WorkoutProvider`. All 7 tests passed.
