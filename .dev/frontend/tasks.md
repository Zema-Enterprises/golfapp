# Frontend Tasks

**Last Updated**: 2026-02-07

## Setup & Configuration
- [x] Initialize Flutter project (Flutter 3.38.5 installed)
- [x] Configure platforms (iOS, Android, Web, Linux)
- [x] Set up project structure (feature-first)
- [x] Install core dependencies
- [x] Configure linting

---

## Core Infrastructure

### ✅ API Client (Completed 2026-02-05)
- [x] Dio HTTP client with base configuration
- [x] Auth interceptor (JWT token attachment)
- [x] Refresh token interceptor (auto-refresh on 401)
- [x] API exception handling
- [x] **All endpoint services created:**
  - Auth repository (register, login, logout, PIN operations)
  - Children repository (CRUD operations)
  - Drills repository (list, get, categories)
  - Sessions repository (generate, complete, history)
  - Progress repository (stats, streak)
  - Avatar repository (shop, purchase, equip)
  - Settings repository (get, update)

### ✅ Local Database (Completed 2026-02-05)
- [x] Drift (SQLite) database setup
- [x] Tables defined:
  - LocalChildren, LocalDrills
  - LocalSessions, LocalSessionDrills
  - LocalAvatarItems, LocalOwnedItems
  - LocalSettings, SyncQueue
- [x] CRUD operations for all tables
- [x] Sync tracking (needsSync flags)

### ✅ Sync Service (Completed 2026-02-05)
- [x] Connectivity monitoring (online/offline detection)
- [x] Sync queue for pending operations
- [x] Auto-sync on connectivity change
- [x] Background sync timer (5 min interval)
- [x] Server data refresh (drills, avatar items)
- [x] Max offline duration check (7 days)

### ✅ Navigation (Completed 2026-02-07)
- [x] GoRouter basic setup
- [x] Auth-aware routing
- [x] Auth routes (login, register, PIN setup, forgot password)
- [x] Dashboard routes (add child)
- [x] Session routes (session preview)
- [x] Session routes (kid-mode play, drill, complete, summary)
- [x] Avatar & Progress routes
- [x] Settings routes
- [x] **Bottom navigation bar** (Home | Progress | Avatar | Settings)
- [x] StatefulShellRoute with tab state preservation
- [ ] Deep linking configuration (deferred)
- [ ] Route guards for child mode (deferred)

### ✅ State Management
- [x] Riverpod setup
- [x] Auth provider with state notifier
- [x] Children provider with state notifier
- [x] Sessions provider (active session + history)
- [x] Avatar provider
- [x] Settings provider
- [x] Progress providers (FutureProviders)
- [x] Drills providers (FutureProviders)
- [x] Sync service provider

---

## Features: Auth (Completed 2026-02-05)
- [x] Login screen (connected to API)
- [x] Register screen (connected to API)
- [x] Forgot password screen
- [x] PIN setup screen (with confirmation flow)
- [x] Auth state management (with PIN tracking)
- [x] Auth-aware routing (redirect to PIN setup for new users)

## Features: Dashboard (In Progress 2026-02-05)
- [x] Parent dashboard screen
- [x] Child profile cards
- [x] Add child flow
- [x] **Duration selection (10/15/20 min)**
- [x] Quick session start (routes to session preview)

## Features: Sessions (Completed 2026-02-07)
- [x] Session generation (via active session provider)
- [x] Session preview screen
- [x] Kid mode ready screen (countdown 3-2-1-GO!)
- [x] Kid mode drill screen (with instructions, "I Did It!" button)
- [x] PIN verification dialog (4-digit parent PIN check)
- [x] Session complete screen (trophy celebration + confetti)
- [x] Session summary screen (drills recap + stars earned)
- [x] Star reward animation (burst + scale-in stars)

## Features: Avatar (Completed 2026-02-07)
- [x] Avatar display widget
- [x] Star balance widget
- [x] Item shop screen (**shows availableStars**)
- [x] Equip/unequip flow
- [x] Purchase flow with confirmation
- [ ] Unlock animations (deferred)

## Features: Progress (Completed 2026-02-07)
- [x] Progress overview screen
- [x] Star stats (available + total earned)
- [x] Streak display with weekly progress bar
- [x] Achievement badges (6 milestones)
- [ ] Star history (deferred)

## Features: Settings (Completed 2026-02-07)
- [x] Settings screen
- [x] **Streak goal configuration** (dialog picker)
- [x] Notification toggle
- [x] Sound toggle
- [x] Logout with confirmation
- [ ] Change PIN flow (route placeholder)
- [ ] Account management (deferred)

## Shared Components
- [x] Primary button
- [x] Secondary button
- [x] Kid action button (drafted)
- [x] PIN verification dialog
- [x] Star reward animation
- [ ] Drill card
- [x] Child profile card
- [x] Duration selector
- [x] Star balance widget
- [x] Avatar display widget
- [ ] Streak badge
- [x] Loading indicator
- [x] Error view
- [x] Empty state

---

## Constants Updated (2026-02-05)
- Stars per drill: 2 (was 3)
- Session durations: 10, 15, 20 minutes
- Duration to drill count: 10→2, 15→3, 20→4
- Max offline days: 7
- Streak goals: DAILY, 5x, 3x, 2x per week

---

## Next Priority
1. ~~Connect auth screens to API~~ ✅
2. ~~Build dashboard screen~~ ✅
3. ~~Build session flow screens (kid mode)~~ ✅
4. ~~Build avatar shop~~ ✅
5. ~~Build progress screens~~ ✅
6. ~~Build settings screen~~ ✅
7. ~~Add bottom navigation bar (Home | Progress | Avatar | Settings)~~ ✅
8. Polish & edge cases

---

## File Structure

```
mobile/lib/
├── app.dart
├── main.dart
├── core/
│   ├── api/
│   │   ├── api_client.dart       ✅
│   │   ├── api_exceptions.dart   ✅
│   │   ├── auth_interceptor.dart ✅
│   │   └── api.dart              ✅
│   ├── config/
│   │   └── constants.dart        ✅ (updated)
│   ├── database/
│   │   ├── database.dart         ✅ (NEW)
│   │   ├── tables.dart           ✅ (NEW)
│   │   └── database_exports.dart ✅ (NEW)
│   ├── services/
│   │   ├── sync_service.dart     ✅ (NEW)
│   │   └── services.dart         ✅ (NEW)
│   └── storage/
│       └── secure_storage.dart   ✅
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart  ✅ (PIN methods added)
│   │   │   └── user.dart             ✅
│   │   ├── providers/
│   │   │   └── auth_provider.dart    ✅
│   │   └── presentation/
│   │       └── screens/              ✅
│   ├── children/
│   │   ├── data/
│   │   │   ├── child.dart            ✅ (NEW)
│   │   │   ├── children_repository.dart ✅ (NEW)
│   │   │   └── children_data.dart    ✅ (NEW)
│   │   ├── presentation/
│   │   │   └── screens/
│   │   │       └── add_child_screen.dart ✅ (NEW)
│   │   └── providers/
│   │       └── children_provider.dart ✅ (NEW)
│   ├── drills/
│   │   ├── data/
│   │   │   ├── drill.dart            ✅ (NEW)
│   │   │   ├── drills_repository.dart ✅ (NEW)
│   │   │   └── drills_data.dart      ✅ (NEW)
│   │   └── providers/
│   │       └── drills_provider.dart  ✅ (NEW)
│   ├── sessions/
│   │   ├── data/
│   │   │   ├── session.dart          ✅ (NEW)
│   │   │   ├── sessions_repository.dart ✅ (NEW)
│   │   │   └── sessions_data.dart    ✅ (NEW)
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── session_preview_screen.dart ✅
│   │   │   │   ├── kid_ready_screen.dart       ✅ (NEW)
│   │   │   │   ├── kid_drill_screen.dart       ✅ (NEW)
│   │   │   │   ├── session_complete_screen.dart ✅ (NEW)
│   │   │   │   └── session_summary_screen.dart ✅ (NEW)
│   │   │   └── widgets/
│   │   │       ├── pin_verification_dialog.dart ✅ (NEW)
│   │   │       └── star_reward_animation.dart  ✅ (NEW)
│   │   └── providers/
│   │       └── sessions_provider.dart ✅ (NEW)
│   ├── progress/
│   │   ├── data/
│   │   │   ├── progress.dart         ✅
│   │   │   ├── progress_repository.dart ✅
│   │   │   └── progress_data.dart    ✅
│   │   ├── presentation/
│   │   │   └── screens/
│   │   │       └── progress_screen.dart ✅ (NEW)
│   │   └── providers/
│   │       └── progress_provider.dart ✅
│   ├── avatar/
│   │   ├── data/
│   │   │   ├── avatar.dart           ✅
│   │   │   ├── avatar_repository.dart ✅
│   │   │   └── avatar_data.dart      ✅
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── avatar_shop_screen.dart ✅ (NEW)
│   │   │   └── widgets/
│   │   │       └── avatar_display.dart     ✅ (NEW)
│   │   └── providers/
│   │       └── avatar_provider.dart  ✅
│   └── settings/
│       ├── data/
│       │   ├── settings.dart         ✅
│       │   ├── settings_repository.dart ✅
│       │   └── settings_data.dart    ✅
│       ├── presentation/
│       │   └── screens/
│       │       └── settings_screen.dart ✅ (NEW)
│       └── providers/
│           └── settings_provider.dart ✅
├── routing/
│   └── router.dart                   ✅
└── shared/
    ├── theme/                        ✅
    └── widgets/
        ├── buttons.dart              ✅
        ├── state_views.dart          ✅
        ├── child_profile_card.dart   ✅ (NEW)
        ├── duration_selector.dart    ✅ (NEW)
        └── widgets.dart              ✅
```
