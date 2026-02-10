# Unified Project Document

# Unified Project Documentation

## Project Requirements Document

### 1. Project Overview

Junior Golf Playbook is a mobile app that helps parents of 4–10-year-old children run short, structured golf practice sessions without being golf experts themselves. The app automatically generates three to four age-appropriate drills that take 10–20 minutes to complete, guides kids through each drill in a bright, simple Kid Mode, and then asks parents to verify completion with a secure PIN. As kids finish drills, they earn stars and unlock avatar items, turning practice into an engaging, game-like experience.

We’re building this app to solve two main problems: first, non-golfer parents often don’t know how to plan or lead practice sessions, and second, kids quickly lose interest in repetitive drills. Success means parents can run sessions easily, sessions work offline and sync later, honest drill tracking via a parent PIN, clear separation between Parent Mode and Kid Mode, push notifications to maintain streaks, and a rewarding free tier with optional in-app purchases for extra drills and items.

### 2. In-Scope vs. Out-of-Scope

**In-Scope (MVP Features):**

*   Parent & Child Profiles with secure 4–6 digit Parent PIN
*   Step-by-step onboarding tutorial covering Parent Mode and Kid Mode
*   Auto-generated guided practice sessions (3–4 drills, 10–20 minutes)
*   Kid Mode UI: large tappable cards, minimal text, bold visuals
*   Parent Mode UI: drill details, session controls, settings
*   Age-based drill library (4–6, 6–8, 8–10 years) with setup, cues, mistakes, criteria, visuals
*   PIN-verified drill completion and honest tracking
*   Star & avatar reward system (hats, shirts, shoes, club skins, mystery items)
*   Progress dashboard showing stars, weekly sessions, streaks, suggested focus
*   Offline support: local caching and automatic sync on reconnect
*   Push notifications for practice reminders, streak alerts, unclaimed rewards
*   Freemium model with free core drills and optional in-app purchases
*   Basic Settings & Help/FAQ for parents (edit child, change PIN, app usage)

**Out-of-Scope (Phase 1):**

*   Multi-language support (English only at launch)
*   Calendar integration or future session scheduling
*   Social sharing, leaderboards, or coach/academy logins
*   Enhanced legal compliance beyond basic cloud auth (COPPA/GDPR extras)
*   Pre-made branding assets (logo, exact colors, fonts)—these will be designed later

### 3. User Flow

A new parent opens the app and sees a friendly welcome screen with Sign Up and Sign In buttons. If they choose Sign Up, they enter an email, create a password, and set a 4–6 digit Parent PIN. The app uses Firebase Auth to register the account, then immediately guides the parent to add one or more children by entering each child’s name, age band, and skill level. A simple avatar placeholder appears for each child, ready for future customization.

Once profiles are in place, a quick interactive tutorial shows the parent where to edit child info, change their PIN, and view progress metrics in Parent Mode. It then switches to Kid Mode to demonstrate the large drill cards and single-tap actions. To start practice, the parent or child taps Start Practice on the child’s card. The app generates three to four drills, runs the session in Kid Mode with a PIN gate at completion of each drill, shows a summary screen with stars and streak updates, and prompts avatar customization if new items are unlocked. The cycle repeats, with optional push notifications reminding families to keep their streaks alive.

### 4. Core Features

*   **Authentication & Profiles:** Email/password signup with Firebase Auth; custom 4–6 digit Parent PIN; multiple child profiles storing name, age, skill, avatar state
*   **Onboarding Tutorial:** Guided tour of Parent Mode and Kid Mode to build user confidence
*   **Guided Practice Sessions:** Automatic session creation (3–4 drills, 10–20 minutes) with review and reorder in Parent Mode
*   **Kid Mode Experience:** Full-screen drill visuals, minimal text, single primary action per screen
*   **Drill Library & Skill Pathways:** Drills grouped by age band, with setup steps, child action, parent cues, common mistakes, success criteria, and visuals
*   **PIN-Verified Completion:** Parent PIN required to confirm each drill; offline queue and sync on reconnect
*   **Stars & Avatar Reward System:** Stars per drill, streak bonuses; unlockable hats, shirts, shoes, club skins, mystery rewards; avatar equip screen
*   **Progress Dashboard & Suggested Focus:** Tracks total stars, weekly sessions, streaks; suggests next drill based on history
*   **Offline Support & Data Sync:** Cached drill content and session data stored locally; automatic sync when online
*   **Push Notifications:** Reminders for streak maintenance, unclaimed stars, configurable daily/weekly frequency
*   **Settings & Help:** Edit child profiles, change PIN, manage account; in-app FAQ covering all app functions

### 5. Tech Stack & Tools

*   **Mobile Framework:** React Native with TypeScript for cross-platform iOS and Android support
*   **Auth & Storage:** Firebase Auth for user login; Supabase or Firebase Firestore for drill data, session results, stars, streaks, avatar unlocks
*   **Local Caching:** React Native AsyncStorage for offline drill library and session queues
*   **Analytics:** Firebase Analytics to track session starts, drill completion, reward unlocks
*   **Push Notifications:** Firebase Cloud Messaging (FCM) for reminders and alerts
*   **Dev Tools:** VS Code with ESLint, Prettier, and optional AI coding assistance plugins
*   **Design Assets:** To be created—bright, sporty color palette; accessible typography; micro-animations for rewards

### 6. Non-Functional Requirements

*   **Performance:** App launch ≤ 2s; session start ≤ 1s; offline interactions instantaneous
*   **Security:** HTTPS/TLS for all API calls; encrypted PIN storage; strict Firebase/Supabase rules per user
*   **Reliability:** Core flows usable offline; eventual consistency on sync; 99.5% backend uptime
*   **Usability & Accessibility:** Tap targets ≥ 44px; high-contrast text; minimal Kid Mode text; supportive animations
*   **Scalability:** Backend designed for hundreds of thousands of users; modular drill library for easy expansion

### 7. Constraints & Assumptions

*   English-only interface at launch
*   Parent PIN limited to 4–6 digits; no biometrics in MVP
*   No calendar, social, or coach-specific features in Phase 1
*   Basic cloud auth management; no deep legal compliance layers for COPPA/GDPR
*   Reliance on Firebase/Supabase pay-as-you-go tiers
*   Devices have at least occasional internet access for sync and notifications
*   New design assets will follow a “bright, sporty” kid-friendly theme

### 8. Known Issues & Potential Pitfalls

*   Offline sync conflicts if sessions run on multiple devices simultaneously—use timestamps and last-write-wins or merge logic
*   Mobile OS may delay or suppress push notifications—offer in-app reminder badges
*   Frequent PIN prompts could frustrate users—consider batching PIN entry for multiple drills in a row
*   Micro-animations may stutter on older devices—optimize asset sizes and animation performance
*   Risk of data loss if the app crashes during an offline session—implement checkpointed writes to local storage
*   Large drill visuals could bloat app size—use SVGs or lazy-load images

## App Flow Document

### Onboarding and Sign-In/Sign-Up

When a new user opens Junior Golf Playbook, they see a clean welcome screen with two buttons: Sign Up and Sign In. If they tap Sign Up, they enter an email, password, and then choose a 4–6 digit Parent PIN. The app registers them via Firebase Auth and immediately guides them to add child profiles. If they tap Sign In, they just enter their email and password. Forgot Password sends a reset link to their email. To sign out, they go to Settings and tap Sign Out. If they ever forget their PIN, they use Change PIN in Settings, authenticate with their account password, and set a new code.

### Main Dashboard or Home Page

After logging in, parents arrive at the Parent Mode dashboard, which shows a header with the app title and a Settings icon. Below that is a progress bar area displaying total stars, sessions completed this week, and current streak, plus a Suggested Focus hint. The main area lists each child’s card in a scrollable view, showing name, age band, avatar image, and a prominent Start Practice button. A toggle at the top right lets parents switch to Kid Mode. From the dashboard, they can add or edit children or dive into any practice session.

### Detailed Feature Flows and Page Transitions

Tapping Add Child opens a form screen where the parent enters name, selects age band, and sets skill level. Saving returns them to the dashboard with the new card visible. On first use, a guided tutorial highlights editing child info, changing PIN, and viewing stats, then switches to Kid Mode to show large drill cards. When practice begins, tapping Start Practice brings up a review screen of the three or four generated drills in Parent Mode. Parents can reorder or remove drills before starting. Tapping Begin switches to Kid Mode. Each drill displays a graphic and a Go button; after action, the child taps Drill Complete, which triggers a PIN overlay. After PIN entry, the app awards a star and moves to the next drill. At session end, a summary screen animates stars and streak bonuses. If new avatar items unlocked, a mystery animation runs, leading to the Avatar screen where kids tap or drag to equip items. A Done button returns to the Parent Mode dashboard.

### Settings and Account Management

In Parent Mode, the gear icon takes users to Settings, which includes Account Info (email, Change Password, Sign Out), Child Profiles (list of children with edit screens for name, age band, skill level, avatar reset), Parent PIN (enter account password, then set new 4–6 digit PIN), Notifications (toggle daily/weekly reminders, streak or reward alerts), and Help & FAQ (instructions on sessions, modes, streaks). A back arrow always returns them to the main dashboard.

### Error States and Alternate Paths

If parents enter wrong login credentials, a clear error invites them to retry. On Forgot Password, submitting an unknown email triggers an alert. After three wrong PIN entries, the app suggests resetting the PIN via Settings. Launching the app offline before the drill library is cached shows a prompt to connect to the internet. During an offline session, a banner notes that progress will sync when back online. If sync fails after reconnection, a badge on the Settings icon alerts the user to retry. Trying to start practice without child profiles pops up a dialog directing users to add a child first.

### Conclusion and Overall App Journey

Parents start by signing up with email, password, and PIN, then add children and complete a quick tutorial in both Parent and Kid Modes. Each practice session flows from session generation to interactive drill screens, PIN-verified completion, and rewarding star or avatar animations. The persistent dashboard offers progress metrics and suggested focus, while Settings and Help remain a tap away. Offline support and automatic sync ensure practice can happen anywhere, and push notifications bring families back when momentum wanes, creating a reliable, playful learning loop.

## Tech Stack Document

### Frontend Technologies

*   React Native (TypeScript): Cross-platform framework for building iOS and Android apps with one codebase
*   React Navigation: Library for handling in-app navigation and screen transitions
*   React Native AsyncStorage: Local key-value storage for caching drills and session data offline
*   Lottie or similar: For lightweight micro-animations when stars are earned or items unlocked
*   ESLint & Prettier: Code quality and formatting tools to keep the codebase clean and consistent

### Backend Technologies

*   Firebase Auth: User authentication via email/password and secure sessions
*   Supabase or Firebase Firestore: Real-time database for storing drill content, session results, star balances, streaks, and avatar items
*   Cloud Functions (Firebase) or Supabase Functions: Server-side logic for generating sessions, awarding stars, and handling sync conflicts

### Infrastructure and Deployment

*   Version Control: Git with GitHub or GitLab for code hosting and collaboration
*   CI/CD: GitHub Actions or GitLab CI for automated testing and builds on merge requests
*   App Distribution: Expo or Fastlane for building and publishing to Apple App Store and Google Play Store
*   Monitoring: Sentry for crash reporting and performance monitoring

### Third-Party Integrations

*   Firebase Analytics: Track user events like session start, drill complete, reward unlock
*   Firebase Cloud Messaging (FCM): Push notifications for reminders and alerts
*   Optional In-App Purchase SDK: For handling freemium purchases and premium content unlocks

### Security and Performance Considerations

*   Authentication: HTTPS/TLS for all API calls; Firebase rules restricting data access per user
*   Data Protection: Encrypt sensitive data like Parent PIN; never store PIN in plain text
*   Performance: Lazy-load images and animations; code splitting per screen; use lightweight SVGs
*   Offline Handling: Robust queue mechanism for session data; conflict resolution logic based on timestamps

### Conclusion and Overall Tech Stack Summary

This stack leverages React Native and TypeScript for a unified mobile codebase, Firebase/Supabase for secure and real-time backend services, and AsyncStorage for offline support. CI/CD pipelines and monitoring tools ensure reliability, while Firebase Analytics and FCM keep families engaged. The chosen technologies align with goals of fast iteration, offline capability, honest tracking, and a playful user experience.

## Frontend Guidelines Document

### Frontend Architecture

We use React Native with TypeScript for a single codebase running on iOS and Android. Components are organized by feature (e.g., drills, sessions, avatars) to keep related files together. Navigation is handled by React Navigation, dividing Parent Mode and Kid Mode into separate stacks. State lives in a combination of React Context for global data (like user info and settings) and local component state for UI interactions. This setup supports easy scaling, clear separation of concerns, and good performance.

### Design Principles

Our UI is clean, playful, and respectful. We balance kid-friendly visuals with an uncluttered layout that parents appreciate. Key principles include usability (simple flows, clear calls to action), accessibility (large tap targets, high-contrast text), and responsiveness (layouts adapt to phone sizes). We favor bold visuals in Kid Mode and compact lists in Parent Mode.

### Styling and Theming

We use a CSS-in-JS solution like Styled Components or Emotion for scoped styling and theming. The theme includes a bright, sporty palette (greens, blues, warm accents) and accessible font sizes. We follow a design system approach with tokens for spacing, typography, and colors to ensure consistency. Kid Mode uses larger fonts and buttons; Parent Mode uses slightly smaller, denser lists.

### Component Structure

Components are grouped by feature folder (e.g., `/components/DrillCard`, `/components/AvatarCustomizer`). Each folder has the main component file, styles file, and test file. Shared UI pieces like buttons, headers, and icons live in a `common` folder. This structure promotes reusability and easy discovery.

### State Management

We use React Context and Hooks for state like user profile, child list, and settings. For drill sessions and offline queues, we rely on a lightweight state manager like Zustand or Redux Toolkit Query. This ensures predictable updates and easy data syncing without over-engineering.

### Routing and Navigation

React Navigation manages screen stacks. Parent Mode has its own stack, starting at Dashboard, Profile Management, Session Review, and Settings. Kid Mode is a separate stack that starts at Drill Screen and ends at Session Summary. A top-level switch determines which stack to show based on user action.

### Performance Optimization

We lazy-load drill visuals and heavy animation assets. Screens are code-split by navigation routes to reduce initial bundle size. We memoize components with `React.memo` and optimize list rendering with `FlatList` and `keyExtractor`. Image assets use SVGs or compressed PNGs.

### Testing and Quality Assurance

We write unit tests for pure functions (e.g., session generation logic) with Jest. We use React Native Testing Library for component and integration tests. End-to-end tests run in Detox or Cypress to cover flows like signup, session run, and avatar unlock. CI pipelines run tests on each pull request.

### Conclusion and Overall Frontend Summary

Our frontend approach combines React Native and TypeScript with a feature-based component structure and robust state management. We follow clear design principles for usability and accessibility, apply a consistent styling system, and optimize for performance and offline support. This foundation makes it easy to maintain, expand, and deliver a fun, reliable experience for parents and their junior golfers.

## Implementation Plan

1.  **Setup & Planning:** Create the Git repo, install React Native (TypeScript), initialize Firebase/Supabase, and configure ESLint/Prettier.
2.  **Authentication Module:** Build signup/signin screens, integrate Firebase Auth, and add Parent PIN logic.
3.  **Profile Management:** Create child profile CRUD UI and backend tables for child data.
4.  **Drill Library Backend:** Structure drill content in Firestore or Supabase, including visuals and metadata.
5.  **Onboarding Tutorial:** Implement a step-by-step in-app guide using a library like react-native-walkthrough.
6.  **Session Generation:** Write serverless functions to auto-generate drill sessions by age band.
7.  **Kid Mode UI:** Build full-screen drill cards with Go and Drill Complete buttons.
8.  **PIN Verification Flow:** Add PIN overlay, verify code, award stars, and advance to next drill.
9.  **Session Summary & Rewards:** Implement summary screen, star tally animations, and unlock logic for avatars.
10. **Avatar Customization:** Create avatar screen with drag-and-drop or tap-to-equip interactions.
11. **Progress Dashboard:** Build dashboard with stars, sessions, streaks, and suggested focus logic.
12. **Offline Support:** Integrate AsyncStorage for caching drills and queuing session data; add sync logic.
13. **Push Notifications:** Configure FCM, build notification scheduling, and in-app handling.
14. **Settings & Help:** Develop settings screens for account, PIN, notifications, and FAQ content.
15. **Styling & Theming:** Apply design system tokens, color theme, typography, and micro-animations.
16. **Testing & QA:** Write unit, integration, and end-to-end tests; fix bugs and polish flows.
17. **Deployment:** Configure CI/CD pipelines, build production apps, and release to App Store and Play Store.
18. **Monitoring & Analytics:** Set up Sentry for crash reporting and Firebase Analytics dashboards.
19. **Review & Feedback:** Conduct beta tests with a small group of parents, gather feedback, and iterate.
20. **Launch:** Final checks, update store listings, and announce the release.

This plan provides a clear, step-by-step path to build, test, and launch Junior Golf Playbook’s MVP, ensuring each core feature is delivered and validated before moving to the next stage.


---
**Document Details**
- **Project ID**: bc0ded31-54a9-4f61-91a5-233ceb4d22e3
- **Document ID**: cdad4a54-5d15-44a2-846d-2de9a8ea3bab
- **Type**: custom
- **Custom Type**: unified_project_document
- **Status**: completed
- **Generated On**: 2025-12-12T01:10:04.835Z
- **Last Updated**: 2025-12-12T01:10:07.504Z
