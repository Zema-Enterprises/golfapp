# Backend Structure Document

# Junior Golf Playbook - Backend Architecture

This document outlines the backend architecture, database setup, APIs, hosting, security, and infrastructure for the Junior Golf Playbook app.

---

## 1. Architecture Overview

We're using a **containerized Node.js backend** with PostgreSQL database, designed for easy local development and production deployment.

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Environment                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   ┌──────────────────┐      ┌──────────────────┐           │
│   │   Node.js API    │      │    PostgreSQL    │           │
│   │   (Fastify +     │◄────►│    Database      │           │
│   │    Prisma)       │      │                  │           │
│   │   Port: 3000     │      │   Port: 5432     │           │
│   └──────────────────┘      └──────────────────┘           │
│            │                                                 │
│            │ (Future: Add as needed)                        │
│            ▼                                                 │
│   ┌──────────────────┐      ┌──────────────────┐           │
│   │      Redis       │      │    File Storage  │           │
│   │   (Caching)      │      │    (S3/R2)       │           │
│   └──────────────────┘      └──────────────────┘           │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Design Patterns & Frameworks

| Pattern | Implementation | Purpose |
|---------|----------------|---------|
| **RESTful API** | Fastify routes | Clean, predictable endpoints |
| **Repository Pattern** | Prisma ORM | Database abstraction |
| **Service Layer** | Module services | Business logic isolation |
| **Dependency Injection** | Fastify plugins | Testable, modular code |
| **Schema Validation** | Zod + Fastify | Runtime type safety |

---

## 2. Database Management

### Technology: PostgreSQL 16

**Why PostgreSQL?**
- ACID compliance for data integrity
- Native JSON support for flexible schemas
- Robust indexing and query optimization
- Excellent tooling and community support
- Proven scalability

### ORM: Prisma

**Why Prisma?**
- Type-safe database queries
- Auto-generated TypeScript types
- Visual database browser (Prisma Studio)
- Easy migrations with version control
- Query performance optimization

### Data Model

```
┌────────────────┐      ┌────────────────┐
│     Parent     │      │     Child      │
├────────────────┤      ├────────────────┤
│ id (UUID)      │──┐   │ id (UUID)      │
│ email          │  │   │ parentId (FK)  │◄──┘
│ passwordHash   │  │   │ name           │
│ pinHash        │  └──►│ ageBand        │
│ settings       │      │ skillLevel     │
│ createdAt      │      │ totalStars     │
└────────────────┘      │ avatarState    │
                        └───────┬────────┘
                                │
            ┌───────────────────┼───────────────────┐
            ▼                   ▼                   ▼
    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
    │   Session    │    │    Streak    │    │ ChildAvatar  │
    ├──────────────┤    ├──────────────┤    │    Item      │
    │ id           │    │ id           │    ├──────────────┤
    │ childId (FK) │    │ childId (FK) │    │ childId (FK) │
    │ status       │    │ current      │    │ itemId (FK)  │
    │ starsEarned  │    │ longest      │    │ equipped     │
    │ startedAt    │    │ lastSession  │    │ unlockedAt   │
    │ completedAt  │    │ weeklyCount  │    └──────────────┘
    └──────┬───────┘    └──────────────┘
           │
           ▼
    ┌──────────────┐      ┌──────────────┐
    │ SessionDrill │      │    Drill     │
    ├──────────────┤      ├──────────────┤
    │ id           │      │ id           │
    │ sessionId(FK)│◄────►│ title        │
    │ drillId (FK) │      │ ageBand      │
    │ order        │      │ skillCategory│
    │ completed    │      │ duration     │
    │ starsEarned  │      │ content      │
    │ verifiedAt   │      │ isPremium    │
    └──────────────┘      └──────────────┘
                                │
                                ▼
                        ┌──────────────┐
                        │  AvatarItem  │
                        ├──────────────┤
                        │ id           │
                        │ type (enum)  │
                        │ name         │
                        │ imageUrl     │
                        │ unlockStars  │
                        │ rarity       │
                        └──────────────┘
```

### Data Practices

| Practice | Implementation |
|----------|----------------|
| **Backups** | Automated daily PostgreSQL backups |
| **Migrations** | Prisma migrations in version control |
| **Seeding** | Prisma seed scripts for drill data |
| **Soft Deletes** | Optional `deletedAt` for recoverable data |
| **Audit Logs** | `createdAt`, `updatedAt` on all tables |

---

## 3. API Design

### REST Endpoints

All endpoints prefixed with `/api/v1/`

#### Authentication

```
POST   /auth/register       # Parent signup
POST   /auth/login          # Login (returns JWT)
POST   /auth/refresh        # Refresh access token
POST   /auth/forgot-password
POST   /auth/reset-password
POST   /auth/verify-pin     # Verify PIN for drill completion
PATCH  /auth/change-pin     # Update PIN (requires password)
```

#### Children Management

```
GET    /children            # List parent's children
POST   /children            # Add child profile
GET    /children/:id        # Get child details
PATCH  /children/:id        # Update child
DELETE /children/:id        # Remove child (soft delete)
```

#### Drills

```
GET    /drills              # List drills (filter: ageBand, skill)
GET    /drills/:id          # Get drill details
GET    /drills/sync         # Sync endpoint (since=timestamp)
```

#### Sessions

```
POST   /sessions/generate   # Generate session for child
GET    /sessions/:id        # Get session details
PATCH  /sessions/:id        # Update session (abandon, etc.)
POST   /sessions/:id/drills/:drillId/complete  # Complete drill
GET    /children/:id/sessions   # Session history for child
```

#### Progress & Rewards

```
GET    /children/:id/progress   # Stars, streaks, stats
GET    /children/:id/avatar     # Avatar state & items
POST   /children/:id/avatar/equip  # Equip/unequip item
GET    /avatar-items            # All available items
```

#### Settings & Sync

```
GET    /sync                # Full sync payload for offline
GET    /users/me            # Current user profile
PATCH  /users/settings      # Update settings
DELETE /users               # Delete account (COPPA)
```

### Response Format

All responses follow a consistent structure:

```typescript
// Success
{
  "success": true,
  "data": { /* payload */ },
  "meta": {
    "timestamp": "2025-12-16T12:00:00Z",
    "requestId": "uuid"
  }
}

// Error
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human readable message",
    "details": [ /* field-level errors */ ]
  },
  "meta": {
    "timestamp": "2025-12-16T12:00:00Z",
    "requestId": "uuid"
  }
}
```

---

## 4. Hosting & Deployment

### Development Environment

```yaml
# docker-compose.yml
services:
  api:
    build: ./server
    ports: ["3000:3000"]
    depends_on: [db]
    environment:
      - DATABASE_URL=postgresql://...
    volumes:
      - ./server/src:/app/src  # Hot reload

  db:
    image: postgres:16-alpine
    ports: ["5432:5432"]
    volumes:
      - postgres_data:/var/lib/postgresql/data
```

### Production Considerations

| Aspect | Recommendation |
|--------|----------------|
| **Hosting** | Docker on Railway, Render, or AWS ECS |
| **Database** | Managed PostgreSQL (Supabase, Neon, RDS) |
| **CDN** | Cloudflare for static assets |
| **SSL** | Auto via hosting platform |
| **Scaling** | Horizontal via container replicas |

---

## 5. Security Measures

### Authentication Flow

```
1. Register → Store bcrypt password hash
2. Login → Validate, issue JWT (15min) + Refresh Token (7d)
3. API Request → Validate JWT in Authorization header
4. Drill Complete → Verify Parent PIN (bcrypt compare)
5. Token Expired → Use refresh token for new JWT
```

### Security Implementations

| Concern | Implementation |
|---------|----------------|
| **Passwords** | bcrypt, 12 salt rounds |
| **PINs** | bcrypt, separate hash, 3-attempt lockout |
| **Transport** | HTTPS/TLS required |
| **JWT** | RS256, short expiry, refresh rotation |
| **Rate Limiting** | 100 req/min per IP, 10/min for auth |
| **Input Validation** | Zod schemas on all endpoints |
| **SQL Injection** | Prisma parameterized queries |
| **CORS** | Strict origin whitelist |

### Data Protection

- All PII encrypted at rest (PostgreSQL)
- PIN never logged or exposed in errors
- Parent can delete all child data (COPPA compliance)
- Session data anonymized for analytics

---

## 6. Monitoring & Logging

### Logging Strategy

```typescript
// Structured JSON logging
{
  "level": "info",
  "timestamp": "2025-12-16T12:00:00Z",
  "requestId": "uuid",
  "userId": "uuid",
  "action": "session.completed",
  "duration": 150,
  "metadata": { /* non-PII context */ }
}
```

### Monitoring Stack (Production)

| Tool | Purpose |
|------|---------|
| **Sentry** | Error tracking, performance |
| **Prometheus** | Metrics collection |
| **Grafana** | Dashboards, alerting |
| **PostgreSQL Logs** | Query performance |

### Key Metrics

- API response times (p50, p95, p99)
- Error rates by endpoint
- Database query performance
- Session completion rate
- Sync success/failure rate

---

## 7. Offline Sync Protocol

### Sync Strategy

1. **Initial Sync**: Full drill library + avatar items
2. **Delta Sync**: Only changed records since last sync
3. **Session Sync**: Batch upload completed sessions
4. **Conflict Resolution**: Server timestamp wins

### Sync Endpoint Response

```typescript
GET /api/v1/sync?since=2025-12-16T00:00:00Z

{
  "data": {
    "drills": {
      "updated": [...],
      "deleted": ["uuid1", "uuid2"]
    },
    "avatarItems": {
      "updated": [...],
      "deleted": []
    },
    "serverTime": "2025-12-16T12:00:00Z"
  }
}
```

---

## 8. Summary

The Junior Golf Playbook backend is built on:

- **Node.js + Fastify**: Fast, type-safe API server
- **PostgreSQL + Prisma**: Robust, type-safe data layer
- **Docker**: Consistent dev/prod environments
- **JWT Authentication**: Stateless, scalable auth
- **Offline-first design**: Delta sync with conflict resolution

This architecture supports the goals of fast iteration, offline capability, honest tracking (PIN verification), and a scalable foundation that grows with the user base.

---

**Document Details**
- **Project ID**: bc0ded31-54a9-4f61-91a5-233ceb4d22e3
- **Last Updated**: 2025-12-16
- **Version**: 2.0 (Node.js + PostgreSQL)
