# App Flow Document

# Junior Golf Playbook App Flow Document

## Onboarding and Sign-In/Sign-Up

When a new user first opens Junior Golf Playbook, they land on a vibrant welcome screen with the app logo and two clear buttons: “Sign Up” and “Sign In.” Tapping Sign Up brings up a form where the parent enters their email address, chooses a password, and then creates a secure 4-6 digit Parent PIN. Once they submit, the app registers them through Firebase Auth and immediately directs them to add child profiles. If the parent already has an account and taps Sign In, they simply enter their email and password and are taken to the main dashboard. If they forget their password, they select Forgot Password, type in their email, and receive a reset link. After resetting, they return to Sign In using the new credentials. To sign out at any time, the parent opens Settings and taps Sign Out, which safely returns them to the welcome screen. If the parent ever forgets their PIN, they use the Change PIN option in Settings—first entering their account password, then choosing a new 4-6 digit code.

## Main Dashboard or Home Page

Immediately after logging in, users arrive at the Parent Mode dashboard. Along the top sits a header with the app title and a Settings icon. Below, a horizontal section displays overall progress: total stars, sessions completed this week, and the current streak indicator, accompanied by a prompt for Suggested Focus. The central area shows each child’s profile card in a scrollable list. Each card includes the child’s name, age band, avatar silhouette or current outfit, and a prominent Start Practice button. A footer or toggle in the header allows switching to Kid Mode. From here, parents can tap any child card to dig deeper or simply tap the mode toggle to hand the device to their child.

## Detailed Feature Flows and Page Transitions

When the parent taps Add Child on the dashboard, the app transitions to a clean form screen. The parent types a name, selects an age band (4–6, 6–8, or 8–10), and sets an initial skill level. Tapping Save returns them to the dashboard where the new child card appears. On first launch, the app automatically launches a guided onboarding tutorial. In Parent Mode, the tutorial highlights the Settings icon, explains how to edit a child profile, and shows where progress metrics live. A final tap moves the user into Kid Mode tutorial, demonstrating the large drill cards, minimal text, and where to tap to complete each drill.

When it’s time to practice, the parent or child taps Start Practice on the child’s card. The app generates a session of three to four age-appropriate drills. In Parent Mode, a review screen lists each drill by name with brief details; parents can reorder drills by dragging or remove a drill if needed. Tapping Begin switches to Kid Mode. In Kid Mode, each drill appears full screen with a bold graphic and a single “Go” button. After watching any quick animation, the child taps “Drill Complete.” That tap brings up the PIN entry overlay. The parent enters their PIN, and the app records the completion, awards the star, and advances to the next drill.

After the final drill, the app presents a session summary. A celebratory animation plays while stars tally on screen and any streak bonus is highlighted. The parent can review the completed drills and star count before tapping Finish. If new avatar items unlocked, a mystery-style reveal animation appears next, prompting the child to visit the Avatar screen. On the Avatar screen, unlocked hats, shirts, shoes, and club skins appear around the golfer silhouette. The child taps any item to preview or drags it onto the avatar to equip it. A Done button then returns them to the Parent Mode dashboard, where their updated avatar now appears on the child’s card.

Whenever the device is offline, the app seamlessly loads drills and avatars from its local cache. Practice sessions continue uninterrupted, with each drill completion queued locally. Once connectivity returns, the app syncs all session data, star balances, and unlocked items back to the central database.

Outside the app, push notifications remind parents when a child’s streak is about to break, when unclaimed stars are waiting, or simply to prompt the next practice. Tapping a notification launches the app and directly opens the relevant child’s card with a prompt to Start Practice.

## Settings and Account Management

Parents access Settings by tapping the gear icon in the top right of Parent Mode. The Settings screen is divided into clear sections. Under Account Info, parents see their email address, a Change Password link, and a Sign Out button. Tapping Change Password prompts the current password and then the new one. Under Child Profiles, parents find a list of all profiles; tapping a child’s name opens an edit screen where they can update the name, adjust the age band or skill level, and even reset that child’s avatar to its default state. The Parent PIN section allows parents to enter their account password and select a new 4-6 digit PIN. In Notifications, parents toggle daily or weekly reminders and choose to receive streak-break or reward alerts. Finally, the Help & FAQ section offers straightforward explanations of how to add children, run sessions, complete drills, and customize avatars. A back arrow at the top returns the user smoothly to the main dashboard.

## Error States and Alternate Paths

If a parent enters the wrong email or password at sign-in, the app displays a friendly error message prompting them to try again. On the Forgot Password screen, submitting an unregistered email leads to an on-screen alert explaining no account exists with that address. Entering the wrong PIN three times in a row triggers a security prompt offering to reset the PIN via the parent’s account password in Settings. When launching the app offline for the very first time, if the drill library is not yet cached, the user sees a clear message: “Please connect to the internet to download practice drills.” During a session, if connectivity drops, a non-intrusive banner appears at the top saying “Offline mode – progress will sync when you’re back online.” If syncing fails after reconnection, a small badge on the Settings icon alerts the parent to retry synchronization. Trying to start practice without having added any children prompts a quick dialog: “No child profiles found. Please add a child to begin practicing.”

## Conclusion and Overall App Journey

From first launch to daily use, Junior Golf Playbook guides parents through a seamless path: they sign up with email and a PIN, add children, and complete a brief tutorial in both Parent and Kid Modes. Each practice cycle flows from session generation to interactive kid-friendly drills, PIN-verified completion, and rewarding star animations. Avatar customization turns progress into a game, while the persistent dashboard offers quick access to profiles, metrics, and suggested focus. Settings and Help remain within easy reach for account management or troubleshooting, and offline support ensures practice can happen anywhere. Push notifications bring families back when momentum wanes, cementing a rhythm of short, structured golf sessions that feel playful for kids and simple for parents.


---
**Document Details**
- **Project ID**: bc0ded31-54a9-4f61-91a5-233ceb4d22e3
- **Document ID**: ab780a52-ae56-42dc-962e-c9fae9fceb4d
- **Type**: custom
- **Custom Type**: app_flow_document
- **Status**: completed
- **Generated On**: 2025-12-12T00:14:16.756Z
- **Last Updated**: 2025-12-12T00:14:19.124Z
