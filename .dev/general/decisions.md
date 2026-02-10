# Architecture Decision Records

## ADR-001: Port Allocation Strategy

**Date**: 2025-12-29  
**Status**: Accepted

### Context
Need consistent, available ports for all project services.

### Decision
Reserve ports 8100-8105 for this project:
- 8100: API Server
- 8101: PostgreSQL
- 8102: Prisma Studio
- 8103: Flutter Web
- 8104-8105: Reserved

### Consequences
- All developers use same ports
- Easy to remember (810x range)
- Avoids conflicts with common services

---

## ADR-002: Node.js LTS Version

**Date**: 2025-12-29  
**Status**: Accepted

### Context
Need stable Node.js version for backend.

### Decision
Use Node.js 22 LTS (current LTS as of Dec 2025).

### Consequences
- Latest language features
- Long-term security updates
- Docker image uses `node:22-alpine`

---

## ADR-003: Feature-First Project Structure

**Date**: 2025-12-29
**Status**: Accepted

### Context
Need maintainable project organization.

### Decision
Both backend and frontend use feature-first structure:
- `/modules/<feature>/` for backend
- `/features/<feature>/` for frontend

### Consequences
- Features are self-contained
- Easy to add/remove features
- Clear ownership boundaries

---

## ADR-004: Spending-Based Star System

**Date**: 2026-02-05
**Status**: Accepted

### Context
Need to decide how stars work for avatar purchases: threshold-based (reach X stars to unlock) vs spending-based (spend stars as currency).

### Decision
Use **spending-based** star system:
- `totalStars` - lifetime earned stars (for stats/display)
- `availableStars` - spendable balance (deducted on purchase)
- Earning stars adds to both fields
- Purchasing deducts only from `availableStars`

### Consequences
- More engaging shop experience (real "currency")
- Requires tracking two star values
- Kids learn resource management
- Clear separation of "earned" vs "spendable"

---

## ADR-005: Duration-Based Session Generation

**Date**: 2026-02-05
**Status**: Accepted

### Context
Need to decide how sessions are created: fixed drill count vs parent-configurable.

### Decision
**Parent selects duration**, system calculates drill count:
- 10 minutes → 2 drills
- 15 minutes → 3 drills
- 20 minutes → 4 drills
- Fixed 2 stars per drill (no variable scoring)

### Consequences
- Flexible for different family schedules
- Predictable rewards (2 stars × drills)
- Simple to understand for kids
- Duration parameter in API (`durationMinutes: "10" | "15" | "20"`)

---

## ADR-006: Parent-Configurable Streak Goals

**Date**: 2026-02-05
**Status**: Accepted

### Context
Need to define what maintains a "streak" - daily practice is unrealistic for families.

### Decision
**Parent configures weekly goal** in settings:
- Options: Daily (7/week), 5x/week, 3x/week, 2x/week
- Streak = consecutive weeks meeting the goal
- Default: 3x/week
- Week resets Sunday midnight (user timezone)

### Consequences
- Realistic for busy families
- Parent controls expectations
- Streak is more achievable
- Requires `streakGoal` in parent settings

---

## ADR-007: Offline-First with Server Timestamp Wins

**Date**: 2026-02-05
**Status**: Accepted

### Context
Need offline support strategy for mobile app.

### Decision
- Offline-first architecture using Drift (SQLite)
- Maximum offline duration: 7 days
- Conflict resolution: **Server timestamp wins**
- Sessions created offline, synced when online

### Consequences
- App works without internet
- Simple conflict resolution (no merge logic)
- Users should sync regularly for best experience
- May lose changes if offline > 7 days
