# Backend Tasks

**Last Updated**: 2026-02-05

## ✅ Setup & Configuration
- [x] Initialize Node.js project with TypeScript
- [x] Configure Fastify with plugins
- [x] Set up Prisma ORM
- [x] Create Docker configuration
- [x] Configure environment validation
- [x] Health check endpoint

---

## ✅ Auth Module (Completed)
- [x] Core Authentication (register, login, refresh, logout)
- [x] Account Management (me, change-password)
- [x] RBAC (roles, permissions seeded)
- [x] GolfApp PIN Extensions (set, verify, change)

---

## ✅ Children Module (Completed)
- [x] Create `children.service.ts`
- [x] Create `children.schema.ts` (Zod validation)
- [x] Create `children.controller.ts`
- [x] Create `children.routes.ts`
- [x] POST `/children` - Add child
- [x] GET `/children` - List children
- [x] GET `/children/:id` - Get child
- [x] PATCH `/children/:id` - Update child
- [x] DELETE `/children/:id` - Remove child
- [x] **Added `availableStars` field to response** (2026-02-05)

---

## ✅ Drills Module (Completed)
- [x] Create `drills.schema.ts` (Zod validation)
- [x] Create `drills.service.ts`
- [x] Create `drills.routes.ts`
- [x] GET `/drills` - List drills (filter by ageBand, skill)
- [x] GET `/drills/:id` - Get drill details
- [x] GET `/drills/categories` - Get skill categories
- [x] Seed drill data (9 drills)

---

## ✅ Sessions Module (Completed + Enhanced)
- [x] Create `sessions.schema.ts` (Zod validation)
- [x] Create `sessions.service.ts`
- [x] Create `sessions.routes.ts`
- [x] POST `/sessions` - Generate session for child
- [x] GET `/sessions` - List session history
- [x] GET `/sessions/:id` - Get session details
- [x] PATCH `/sessions/:id/drills/:drillId` - Complete drill
- [x] POST `/sessions/:id/complete` - Complete session

### 2026-02-05 Updates
- [x] **Changed from `drillCount` to `durationMinutes`** (10/15/20 min)
- [x] **Drill count calculated from duration** (2/3/4 drills)
- [x] **Fixed 2 stars per drill** (STARS_PER_DRILL constant)
- [x] **Session complete updates both `totalStars` AND `availableStars`**
- [x] **Random drill selection** (shuffle for variety)

---

## ✅ Progress Module (Completed + Enhanced)
- [x] Create `progress.service.ts`
- [x] Create `progress.routes.ts`
- [x] GET `/progress/:childId` - Get child stats
- [x] GET `/progress/:childId/streak` - Get streak info
- [x] POST `/progress/:childId/streak` - Update streak

### 2026-02-05 Updates
- [x] **Added `availableStars` to stats response**
- [x] **Parent-configurable streak goals** (DAILY, 5x, 3x, 2x per week)
- [x] **Streak now tracks "weeks meeting goal"** not consecutive days
- [x] **Added `weeklyGoal` and `goalMet` to streak response**

---

## ✅ Avatar Module (Completed + Enhanced)
- [x] Create `avatar.service.ts`
- [x] Create `avatar.routes.ts`
- [x] GET `/avatar/shop` - List items
- [x] GET `/avatar/:childId` - Get child avatar
- [x] POST `/avatar/:childId/purchase` - Buy item
- [x] POST `/avatar/:childId/equip` - Equip item
- [x] DELETE `/avatar/:childId/equip/:type` - Unequip

### 2026-02-05 Updates
- [x] **Purchase deducts from `availableStars`** (not totalStars)
- [x] **Updated avatar item seed data** (13 items, costs 0-100)
- [x] **Aligned costs with wireframes**

---

## ✅ Settings Module (Completed)
- [x] Create `settings.service.ts`
- [x] Create `settings.routes.ts`
- [x] GET `/settings` - Get user settings
- [x] PATCH `/settings` - Update settings

---

## ✅ Database Updates (2026-02-05)
- [x] Added `availableStars` field to Child model
- [x] Created migration `20260205124136_add_available_stars`
- [x] Updated seed data with 13 avatar items
- [x] Regenerated Prisma client

---

## 🔄 Testing (In Progress)

| Module   | Test Status | Priority |
| -------- | ----------- | -------- |
| Auth     | ✅ Has tests | - |
| Children | ✅ Has tests | - |
| Settings | ✅ Has tests | - |
| Drills   | ❌ Needs tests | P1 |
| Sessions | ❌ Needs tests | P1 |
| Progress | ❌ Needs tests | P1 |
| Avatar   | ❌ Needs tests | P1 |

Target: 80%+ coverage

---

## ❌ Not Started

### P0 - Required for MVP
- [ ] Forgot password endpoint (POST `/auth/forgot-password`)
- [ ] Reset password endpoint (POST `/auth/reset-password`)

### P2 - Deferred to v1.1
- [ ] Push notification registration
- [ ] Push notification sending
- [ ] Data sync conflict resolution endpoints
