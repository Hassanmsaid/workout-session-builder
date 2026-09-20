# Workout Session Builder

An offline Flutter app for preparing, running, and resuming a workout session.

## Setup

- Flutter: developed against the stable channel, SDK `3.13.3` (Dart 3.3+). Any recent stable Flutter (3.19+) should work.
- Run `flutter pub get`, then `flutter run`.
- Run tests with `flutter test`.
- No backend, no network permissions, no API keys required.

## What's implemented

- Six starter exercises loaded from a bundled `assets/exercises.json` on first launch.
- Add, edit, delete, reorder (drag handle), complete/reopen exercises.
- A progress summary (completed/total + progress bar) above the list.
- The session is persisted to `shared_preferences` as JSON after every mutation.
- Confirmation dialog before deleting an exercise.
- Empty-state screen if all exercises are removed.

## Key decisions

- **State management: `provider` + a single `ChangeNotifier` (`WorkoutProvider`).** The app has one piece of shared state (the exercise list) and no complex async graphs, so `provider` gives clear state ownership without the boilerplate of Bloc/Riverpod for a problem this size.
- **Persistence: `shared_preferences` storing one JSON-encoded string,** rather than `sqflite`/Hive. The data is a single small list with no querying needs. Trade-off: this doesn't scale to large datasets or partial updates, which is fine here.
- **No `uuid` package.** New exercise IDs are generated from `DateTime.now().microsecondsSinceEpoch`, which is unique enough for a single-user local list and avoids a dependency for one function.
- **Exercise completion is per-exercise, not per-set.** The brief asks for a completion status per exercise; tracking each of the `targetSets`, I judged out of scope for the timebox. Noted under "Unfinished / next".
- **Defensive JSON parsing lives on the model (`Exercise.fromJson`), not the storage layer.** `StorageService` decodes the outer JSON list and it's covered by tests.

## Tests

- `test/workout_provider_test.dart` (unit)
- `test/storage_service_test.dart` (unit)

## Short design question: a timer that survives backgrounding

**Design.** Don't drive the displayed time with `Timer.periodic` ticks alone — OS-level backgrounding can pause or throttle timers, and the countdown will drift or freeze. Instead:

1. Store the timer's state as data, not as a running countdown: `startedAt` (epoch), `plannedDuration`, and `accumulatedPausedDuration` (or simply persist `remainingSeconds` + `startedAt` whenever the timer is running).
2. At any point, compute `elapsed = DateTime.now().difference(startedAt) - accumulatedPausedDuration`, and derive `remaining = plannedDuration - elapsed`. The `Timer.periodic` is only used to trigger a UI repaint every ~200ms–1s; it never owns the "truth" of how much time is left.
3. Use a `WidgetsBindingObserver` to watch `AppLifecycleState`. On `paused`/`inactive`, stop the periodic UI timer (no point repainting an invisible screen) but leave `startedAt` alone. On `resumed`, immediately recompute `remaining` from the wall-clock formula above and resume the UI ticker — the displayed value snaps to the correct time instead of continuing from where it left off.
4. Persist `startedAt`/`plannedDuration` to disk (same `shared_preferences` mechanism as the rest of the session) as soon as the timer starts, so the timer is also correct after the process is killed and relaunched, not just backgrounded — the same wall-clock formula handles both cases uniformly.
5. Fire the "timer finished" event (sound/vibration/navigation) based on the same computed `remaining <= 0`, checked both on each tick and once on `resumed`, so a completion that happened while backgrounded isn't missed.

**Testing.**

- *Unit test* the pure calculation function (e.g. `remainingDuration(now, startedAt, plannedDuration, pausedDuration)`) with an injected/fake `now`, independent of any widget or real clock — assert correct output when `now` is far in the future (simulating a long background period), when paused duration is non-zero, and at/after expiry.
- *Widget test* pumping the timer widget, then driving `WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.paused)` followed by advancing a fake clock and `...resumed`, asserting the displayed time reflects the elapsed wall-clock time rather than having stayed frozen or drifted from ticks that didn't fire.
- *Manual/manual-adjacent test*: start the timer, background the app (home button) or lock the device for longer than the remaining duration, then reopen — the app should show "finished" immediately rather than resuming a stale countdown. Doing this once on both a debug build and, if possible, a release build catches OS-specific throttling differences.

## Unfinished / next steps

Given the timebox, these were left out:

- Per-set tracking (e.g. tapping through set 1/3, 2/3, 3/3) instead of a single completed/not-completed toggle per exercise.
- Add a refresh button to reload the defaults when all exercises are removed (it's working but only when restarting the app).
- The actual rest/exercise timer described in the design question above — the brief explicitly says not to build it.
- Categorized/grouped view or filtering by category — the category field is captured and displayed but not used to organize the list.
- Undo for delete (currently confirmation-only, no snackbar undo).

## Assumptions

- Reordering, editing, and deleting remain available on already-completed exercises, since the brief doesn't say a workout is locked once finished.
