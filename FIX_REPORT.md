# Fix Report: Disappearing Polls

## Issue
Polls would appear briefly and then disappear after 3 seconds, showing "No polls found".

## Cause
The stream logic had a **3-second timeout**. Because the live data stream didn't emit *new* events continuously (which is normal), the timeout would trigger and incorrectly replace the data with a local fallback (which might be empty or stale).

## Resolution
1.  **Removed Strict Timeout**: The `pollsStreamProvider` in `lib/features/polls/providers/poll_providers.dart` now listens to the stream normally without a self-destruct timer.
2.  **Retained Error Handling**: If the stream actually errors (e.g. network fail), it still strictly falls back to local storage.

## Verification
1.  Run `flutter run`.
2.  Polls should load and **stay visible**.
3.  The original "stuck loading" bug is prevented by the **Anonymous Auth** fix applied earlier.
