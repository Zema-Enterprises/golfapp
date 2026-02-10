# Screen Implementation Checklist

## Auth Screens

| Screen | Route | Status | Notes |
|--------|-------|--------|-------|
| Login | `/auth/login` | [ ] | |
| Register | `/auth/register` | [ ] | |
| Forgot Password | `/auth/forgot-password` | [ ] | |
| Reset Password | `/auth/reset-password` | [ ] | Deep link |
| PIN Setup | `/auth/pin-setup` | [ ] | After register |

## Main Screens (Parent Mode)

| Screen | Route | Status | Notes |
|--------|-------|--------|-------|
| Dashboard | `/` | [ ] | Child selector |
| Child Detail | `/child/:id` | [ ] | |
| Add Child | `/child/add` | [ ] | Modal/sheet |
| Settings | `/settings` | [ ] | |
| Profile | `/profile` | [ ] | |

## Session Screens

| Screen | Route | Status | Notes |
|--------|-------|--------|-------|
| Session Preview | `/session/:id` | [ ] | Drill list |
| Session Active | `/session/:id/active` | [ ] | Parent view |
| Session Summary | `/session/:id/summary` | [ ] | Stars earned |

## Kid Mode Screens

| Screen | Route | Status | Notes |
|--------|-------|--------|-------|
| Kid Mode Entry | `/kid-mode/:sessionId` | [ ] | Large UI |
| Drill Display | (nested) | [ ] | Single drill |
| PIN Entry | (dialog) | [ ] | Parent verifies |
| Star Celebration | (overlay) | [ ] | Animation |
| Session Complete | (nested) | [ ] | Summary |

## Avatar Screens

| Screen | Route | Status | Notes |
|--------|-------|--------|-------|
| Avatar View | `/child/:id/avatar` | [ ] | |
| Item Shop | `/child/:id/avatar/shop` | [ ] | |
| Item Detail | (sheet) | [ ] | |

## Progress Screens

| Screen | Route | Status | Notes |
|--------|-------|--------|-------|
| Progress Overview | `/child/:id/progress` | [ ] | |
| Session History | `/child/:id/history` | [ ] | |
| Achievements | `/child/:id/achievements` | [ ] | Future |
