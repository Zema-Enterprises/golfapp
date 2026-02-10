# Project Requirements Document

# Junior Golf Playbook – Project Requirements Document

## 1. Project Overview

Junior Golf Playbook is a mobile app designed to help parents of 4–10-year-old kids run short, structured golf practice sessions without needing expert knowledge. The app auto-generates 10–20 minute drills tailored to each child’s age and skill level, guides them through Kid Mode with big visuals and single-tap actions, and then verifies completion in Parent Mode with a secure PIN. As kids complete drills, they earn stars and unlock fun avatar items, turning practice into a gentle game rather than homework.

We’re building this app to solve two main problems: non-golfer parents who don’t know how to structure practice, and kids who lose interest in repetitive drills. Key success criteria for the first version include seamless offline operation, honest drill tracking via PIN, clear Parent vs. Kid experiences, push notifications to reinforce streaks, and a basic freemium rewards loop that keeps kids motivated.

## 2. In-Scope vs. Out-of-Scope

### In-Scope (MVP Features)

*   Parent & Child Profiles with secure 4–6 digit Parent PIN
*   Step-by-step onboarding tutorial for Parent Mode & Kid Mode
*   Auto-generated guided practice sessions (3–4 drills, 10–20 minutes)
*   Kid Mode UI: large tappable cards, minimal text, bold visuals
*   Parent Mode UI: drill details, session controls, settings
*   Age-based drill library (bands: 4–6, 6–8, 8–10) with visuals, cues, mistakes, success criteria
*   PIN-verified drill completion and honest tracking
*   Star & avatar reward system (unlock hats, shirts, shoes, club skins, mystery items)
*   Progress dashboard: stars, weekly sessions, daily/weekly streaks, suggested focus
*   Offline support with local caching & automatic sync on reconnect
*   Push notifications for practice reminders, streak alerts, unclaimed rewards
*   Freemium model with free core drills and optional in-app purchases
*   Basic Settings & Help/FAQ for parents (edit child, change PIN, app usage)

### Out-of-Scope (Phase 1)

*   Multi-language support (English only at launch)
*   Calendar integration or future session scheduling
*   Social sharing, leaderboards, or coach/academy logins
*   GDPR/COPPA compliance beyond standard cloud-auth rules
*   Custom branding assets (logo, color codes, fonts) — to be designed later

## 3. User Flow

**Paragraph 1:**\
A new parent launches the app, sees a clean welcome screen, and taps “Sign Up.” They enter email/password and choose a 4–6 digit Parent PIN. The app stores credentials in Firebase Auth and creates their Parent profile. Next, they add one or more children by entering each child’s name, age band, and initial skill level. A simple avatar silhouette appears for future customization.

**Paragraph 2:**\
After profiles are set, an interactive tutorial runs: first in Parent Mode (showing where to edit profiles, change PIN, view stats), then in Kid Mode (demonstrating large drills interface). Once onboarded, the parent or child taps “Start Practice” on a child’s card. The app generates 3–4 age-appropriate drills. In Kid Mode, the child follows visuals and taps “Go” then “Drill Complete.” Each completion prompts the parent to enter their PIN. After all drills, a summary screen shows stars earned, streak updates, and unlock animations. Kids then customize their avatar before returning to the dashboard, and the cycle repeats with optional push reminders later.

## 4. Core Features

*   **Authentication & Profiles**\
    • Email/password sign-up via Firebase Auth\
    • Parent account secured by custom 4–6 digit PIN\
    • Multiple child profiles (name, age band, skill level, avatar state)
*   **Onboarding Tutorial**\
    • Guided tour of Parent Mode and Kid Mode controls\
    • Ensures confidence toggling between experiences
*   **Guided Practice Sessions**\
    • Auto-generate 10–20 minute sessions with 3–4 drills\
    • Kid Mode: single-action screens with visuals\
    • Parent Mode: drill details, reorder, start/pause controls
*   **Drill Library & Skill Pathways**\
    • Drills grouped by age: 4–6, 6–8, 8–10\
    • Each drill has setup, child action, parent cue, common mistakes, success criteria, visual
*   **PIN-Verified Completion & Tracking**\
    • Drill finish gated by Parent PIN\
    • Honest tracking, star awarding, streak updating\
    • Offline queue + sync on reconnect
*   **Stars & Avatar Rewards**\
    • Stars per drill and streak bonus\
    • Unlock hats, shirts, shoes, club skins, mystery items\
    • Avatar equip screen with drag-and-drop or tap preview
*   **Progress Dashboard & Suggested Focus**\
    • Weekly/daily session count, star balance, streak indicator\
    • Suggest one drill type based on recent history
*   **Offline Support & Data Sync**\
    • Drill content cached locally via AsyncStorage\
    • Session data queued offline, synced when online
*   **Push Notifications**\
    • Reminders before streak breaks or unclaimed stars\
    • Configurable frequency (daily/weekly)
*   **Settings & Help**\
    • Edit child info, change PIN, manage account\
    • In-app FAQ covering sessions, modes, streaks

## 5. Tech Stack & Tools

*   **Mobile Framework**: React Native with TypeScript
*   **Authentication & Storage**: Firebase Auth (email/password), Supabase or Firebase Realtime/Firestore for drill content, session data, stars, streaks, avatar unlocks
*   **Local Caching**: React Native AsyncStorage
*   **Analytics**: Firebase Analytics (session tracking, drill usage, reward unlocks)
*   **Push Notifications**: Firebase Cloud Messaging (FCM) or equivalent
*   **Development Tools**: VS Code, optional plugin integrations (Cursor for AI coding assistance, ESLint + Prettier for style)
*   **Design Assets**: To be created—sporty, kid-friendly theme; bright greens/blues; accessible typography

## 6. Non-Functional Requirements

*   **Performance**\
    • App launch ≤ 2 seconds on modern devices\
    • Session start ≤ 1 second after tap\
    • Offline UI interactions instantaneous (local cache)
*   **Security**\
    • Encrypt all API traffic via HTTPS/TLS\
    • Secure PIN entry (no PIN stored in plain text)\
    • Firebase/Supabase rules restrict data per user
*   **Reliability & Availability**\
    • Core flows (view drills, run sessions) must work offline\
    • Data sync eventual consistency with conflict resolution\
    • 99.5% backend uptime
*   **Usability & Accessibility**\
    • Large tap targets (≥44px) for kids\
    • High-contrast text for readability\
    • Minimal text in Kid Mode, clear micro-animations
*   **Scalability**\
    • Backend structured to handle growing user base (hundreds of thousands)\
    • Modular drill library for future expansion

## 7. Constraints & Assumptions

*   English-only interface at launch
*   Parent PIN is 4–6 numeric digits—no biometrics in MVP
*   No calendar or scheduling integration in phase 1
*   No social sharing, coach-specific logins, or strict privacy legal flows beyond basic auth
*   Reliance on Firebase/Supabase free or pay-as-you-go tiers
*   Devices have at least intermittent internet for sync and notifications
*   Brand assets will be designed from scratch following the “bright, sporty” theme

## 8. Known Issues & Potential Pitfalls

*   **Offline Sync Conflicts**\
    • Simultaneous sessions on two devices may conflict—use last-write-wins or timestamp merging
*   **Push Notification Delivery**\
    • Mobile OS may delay or suppress notifications—provide in-app reminder fallback
*   **PIN Fatigue**\
    • Frequent PIN prompts could frustrate users—batch PIN entry for multi-drill unlock?
*   **Animation Performance**\
    • Micro-animations on older devices may stutter—optimize asset sizes and frame rates
*   **Data Loss Risk**\
    • App crashes during offline session—implement safe write checkpoints in local storage
*   **Scalability of Drill Library**\
    • Large image assets could bloat app size—use lightweight SVGs or lazy-load visuals

This document serves as the single source of truth for Junior Golf Playbook’s MVP. All subsequent technical specifications (frontend guidelines, backend structure, UI flows, etc.) should reference these requirements to ensure alignment and clarity.


---
**Document Details**
- **Project ID**: bc0ded31-54a9-4f61-91a5-233ceb4d22e3
- **Document ID**: 21c9848d-e1b8-4682-945b-c44422c9e959
- **Type**: custom
- **Custom Type**: project_requirements_document
- **Status**: completed
- **Generated On**: 2025-12-11T00:47:09.170Z
- **Last Updated**: 2025-12-12T01:08:43.947Z
