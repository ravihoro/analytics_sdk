# analytics_sdk

A lightweight Flutter analytics SDK with offline event queuing, identity/session tracking, and batch upload to a backend API.

Built as a reusable package (not app-specific code) so any Flutter app can integrate it with a few lines of setup.

## Features

- Simple public API: `init`, `track`, `screen`, `identify`, `reset`, `flush`
- Anonymous device id + optional user id (pre/post login)
- Session management with idle timeout
- Offline-first event queue using **SQLite**
- Batch HTTP upload with retry (requeue on failure)
- Periodic flush + flush-on-threshold
- Optional `NavigatorObserver` for automatic screen tracking
- Fail-safe design: analytics errors never crash the host app

## Architecture

```text
Host app
  └─ Analytics.track / screen / identify
        ↓
   Enrich event (anonymousId, userId, sessionId, platform)
        ↓
   SQLite event queue
        ↓
   Batch uploader (HTTP)
        ↓
   POST /analytics/events
```
