# Tech Stack Document

# Junior Golf Playbook - Technology Stack

## Overview

This document defines the complete technology stack for the Junior Golf Playbook mobile application. The architecture prioritizes **developer experience**, **scalability**, **offline-first capabilities**, and **containerized deployment**.

---

## Frontend - Mobile Application

### Framework: Flutter (Dart)

| Aspect | Choice | Rationale |
|--------|--------|-----------|
| **Framework** | Flutter 3.x | Single codebase for iOS, Android, Web. Hot reload. Native performance. |
| **Language** | Dart (null-safe) | Strong typing, async/await, great tooling |
| **State Management** | Riverpod 2.x | Type-safe, testable, compile-time safety |
| **Navigation** | GoRouter | Declarative, deep linking support |
| **Local Database** | Drift (SQLite) | Type-safe SQL, offline-first, reactive queries |
| **HTTP Client** | Dio | Interceptors, retry logic, request cancellation |
| **Secure Storage** | flutter_secure_storage | Keychain (iOS) / Keystore (Android) for PIN |

### Key Flutter Packages

```yaml
dependencies:
  # Core
  flutter_riverpod: ^2.4.0       # State management
  go_router: ^12.0.0             # Navigation
  dio: ^5.3.0                    # HTTP client
  
  # Database & Offline
  drift: ^2.14.0                 # SQLite ORM
  connectivity_plus: ^5.0.0      # Network detection
  
  # UI & Animation
  flutter_animate: ^4.3.0        # Declarative animations
  cached_network_image: ^3.3.0   # Image caching
  lottie: ^2.7.0                 # Lottie animations
  
  # Security
  flutter_secure_storage: ^9.0.0 # Secure PIN storage
  crypto: ^3.0.3                 # Hashing utilities
  
  # Push Notifications
  firebase_messaging: ^14.7.0    # FCM for push
  flutter_local_notifications: ^16.0.0
  
  # Utilities
  freezed_annotation: ^2.4.0     # Immutable data classes
  json_annotation: ^4.8.0        # JSON serialization
  intl: ^0.18.0                  # Internationalization ready
```

### Project Structure

```
lib/
├── main.dart
├── app.dart
├── /core
│   ├── /config              # Environment, constants
│   ├── /network             # Dio client, interceptors
│   ├── /database            # Drift database, DAOs
│   ├── /services            # Business logic services
│   └── /utils               # Helpers, extensions
├── /features
│   ├── /auth
│   │   ├── /data            # Repositories, data sources
│   │   ├── /domain          # Entities, use cases
│   │   └── /presentation    # Screens, widgets, providers
│   ├── /sessions
│   ├── /drills
│   ├── /avatar
│   ├── /progress
│   └── /settings
├── /shared
│   ├── /widgets             # Reusable UI components
│   ├── /theme               # Colors, typography, spacing
│   └── /providers           # Global providers
└── /routing
    └── router.dart          # GoRouter configuration
```

---

## Backend - Node.js Server

### Core Technologies

| Layer | Technology | Rationale |
|-------|------------|-----------|
| **Runtime** | Node.js 20 LTS | Stable, async I/O, large ecosystem |
| **Framework** | Fastify | Faster than Express, schema validation, TypeScript |
| **Language** | TypeScript 5.x | Type safety, better DX, refactoring |
| **Database** | PostgreSQL 16 | ACID, JSON support, robust, scalable |
| **ORM** | Prisma | Type-safe queries, migrations, great DX |
| **Validation** | Zod | Runtime type validation, schema-first |
| **Auth** | JWT + bcrypt | Stateless auth, secure password hashing |
| **API Docs** | Swagger/OpenAPI | Auto-generated from schemas |

### Backend Project Structure

```
server/
├── docker-compose.yml
├── Dockerfile
├── package.json
├── tsconfig.json
├── prisma/
│   ├── schema.prisma        # Database schema
│   └── migrations/          # SQL migrations
├── src/
│   ├── index.ts             # Entry point
│   ├── app.ts               # Fastify app setup
│   ├── /config
│   │   ├── env.ts           # Environment validation
│   │   └── database.ts      # DB connection
│   ├── /modules
│   │   ├── /auth
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── auth.schema.ts
│   │   │   └── auth.routes.ts
│   │   ├── /users
│   │   ├── /children
│   │   ├── /drills
│   │   ├── /sessions
│   │   ├── /rewards
│   │   └── /notifications
│   ├── /middleware
│   │   ├── auth.middleware.ts
│   │   ├── error.middleware.ts
│   │   └── logging.middleware.ts
│   ├── /utils
│   └── /types
└── tests/
    ├── /unit
    └── /integration
```

### Database Schema (Prisma)

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Parent {
  id           String    @id @default(uuid())
  email        String    @unique
  passwordHash String
  pinHash      String
  createdAt    DateTime  @default(now())
  updatedAt    DateTime  @updatedAt
  children     Child[]
  settings     Json      @default("{}")
}

model Child {
  id          String    @id @default(uuid())
  parentId    String
  parent      Parent    @relation(fields: [parentId], references: [id], onDelete: Cascade)
  name        String
  ageBand     AgeBand
  skillLevel  SkillLevel @default(BEGINNER)
  totalStars  Int       @default(0)
  avatarState Json      @default("{}")
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
  sessions    Session[]
  unlockedItems ChildAvatarItem[]
  streaks     Streak[]
}

model Drill {
  id              String   @id @default(uuid())
  title           String
  ageBand         AgeBand
  skillCategory   String
  durationMinutes Int      @default(5)
  setup           String
  childAction     String
  parentCue       String
  commonMistakes  String
  successCriteria String
  imageUrl        String?
  videoUrl        String?
  isPremium       Boolean  @default(false)
  createdAt       DateTime @default(now())
  sessionDrills   SessionDrill[]
}

model Session {
  id              String   @id @default(uuid())
  childId         String
  child           Child    @relation(fields: [childId], references: [id], onDelete: Cascade)
  status          SessionStatus @default(IN_PROGRESS)
  totalStarsEarned Int     @default(0)
  startedAt       DateTime @default(now())
  completedAt     DateTime?
  drills          SessionDrill[]
}

model SessionDrill {
  id          String   @id @default(uuid())
  sessionId   String
  session     Session  @relation(fields: [sessionId], references: [id], onDelete: Cascade)
  drillId     String
  drill       Drill    @relation(fields: [drillId], references: [id])
  order       Int
  completed   Boolean  @default(false)
  starsEarned Int      @default(0)
  verifiedAt  DateTime?
}

model AvatarItem {
  id            String   @id @default(uuid())
  type          ItemType
  name          String
  imageUrl      String
  unlockStars   Int      @default(0)
  isPremium     Boolean  @default(false)
  rarity        Rarity   @default(COMMON)
  childItems    ChildAvatarItem[]
}

model ChildAvatarItem {
  id          String     @id @default(uuid())
  childId     String
  child       Child      @relation(fields: [childId], references: [id], onDelete: Cascade)
  itemId      String
  item        AvatarItem @relation(fields: [itemId], references: [id])
  equipped    Boolean    @default(false)
  unlockedAt  DateTime   @default(now())
  
  @@unique([childId, itemId])
}

model Streak {
  id                String   @id @default(uuid())
  childId           String
  child             Child    @relation(fields: [childId], references: [id], onDelete: Cascade)
  currentStreak     Int      @default(0)
  longestStreak     Int      @default(0)
  lastSessionDate   DateTime?
  weeklySessionCount Int     @default(0)
  weekStartDate     DateTime
}

enum AgeBand {
  AGE_4_6
  AGE_6_8
  AGE_8_10
}

enum SkillLevel {
  BEGINNER
  INTERMEDIATE
  ADVANCED
}

enum SessionStatus {
  IN_PROGRESS
  COMPLETED
  ABANDONED
}

enum ItemType {
  HAT
  SHIRT
  SHOES
  CLUB_SKIN
  ACCESSORY
  MYSTERY
}

enum Rarity {
  COMMON
  UNCOMMON
  RARE
  EPIC
  LEGENDARY
}
```

---

## Infrastructure & DevOps

### Docker Configuration

```yaml
# docker-compose.yml
version: '3.8'

services:
  api:
    build:
      context: ./server
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/golfapp
      - JWT_SECRET=${JWT_SECRET}
      - JWT_EXPIRES_IN=7d
    depends_on:
      db:
        condition: service_healthy
    volumes:
      - ./server/src:/app/src  # Hot reload in development
    networks:
      - golfapp-network

  db:
    image: postgres:16-alpine
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=golfapp
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5
    networks:
      - golfapp-network

  # Optional: Add as needed
  # redis:
  #   image: redis:7-alpine
  #   ports:
  #     - "6379:6379"
  #   networks:
  #     - golfapp-network

volumes:
  postgres_data:

networks:
  golfapp-network:
    driver: bridge
```

### Server Dockerfile

```dockerfile
# server/Dockerfile
FROM node:20-alpine AS base
WORKDIR /app

# Dependencies
FROM base AS deps
COPY package*.json ./
RUN npm ci

# Builder
FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npx prisma generate
RUN npm run build

# Production
FROM base AS runner
ENV NODE_ENV=production

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000
CMD ["npm", "start"]
```

---

## API Design

### REST Endpoints

```
Authentication
├── POST   /api/v1/auth/register     # Parent signup
├── POST   /api/v1/auth/login        # Login
├── POST   /api/v1/auth/refresh      # Refresh token
├── POST   /api/v1/auth/forgot-password
├── POST   /api/v1/auth/reset-password
└── POST   /api/v1/auth/verify-pin   # Verify parent PIN

Children
├── GET    /api/v1/children          # List parent's children
├── POST   /api/v1/children          # Add child
├── GET    /api/v1/children/:id      # Get child details
├── PATCH  /api/v1/children/:id      # Update child
└── DELETE /api/v1/children/:id      # Remove child

Drills
├── GET    /api/v1/drills            # List drills (filter by age, skill)
├── GET    /api/v1/drills/:id        # Get drill details
└── GET    /api/v1/drills/sync       # Sync drills for offline (with timestamps)

Sessions
├── POST   /api/v1/sessions/generate # Generate session for child
├── GET    /api/v1/sessions/:id      # Get session details
├── PATCH  /api/v1/sessions/:id      # Update session status
├── POST   /api/v1/sessions/:id/drills/:drillId/complete  # Complete drill with PIN
└── GET    /api/v1/children/:id/sessions  # Session history

Rewards & Progress
├── GET    /api/v1/children/:id/progress   # Stars, streaks, stats
├── GET    /api/v1/children/:id/avatar     # Avatar state & items
├── POST   /api/v1/children/:id/avatar/equip  # Equip item
└── GET    /api/v1/avatar-items            # All available items

Settings & Sync
├── GET    /api/v1/sync              # Full sync payload for offline
├── PATCH  /api/v1/users/settings    # Update parent settings
└── PATCH  /api/v1/users/pin         # Change PIN
```

---

## Security

| Concern | Implementation |
|---------|----------------|
| **Password Storage** | bcrypt with salt rounds 12 |
| **PIN Storage** | bcrypt hash, stored separately |
| **API Authentication** | JWT in Authorization header |
| **Token Refresh** | Refresh token rotation |
| **Transport** | HTTPS/TLS only |
| **Rate Limiting** | Fastify rate-limit plugin |
| **Input Validation** | Zod schemas on all endpoints |
| **SQL Injection** | Prisma parameterized queries |
| **CORS** | Configured per environment |

---

## Offline-First Strategy

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App                          │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│  │  Riverpod   │ │    Dio      │ │    Drift    │       │
│  │   (State)   │ │   (HTTP)    │ │  (SQLite)   │       │
│  └──────┬──────┘ └──────┬──────┘ └──────┬──────┘       │
│         │               │               │               │
│         └───────────────┼───────────────┘               │
│                         │                               │
│                ┌────────┴────────┐                      │
│                │  Sync Manager   │                      │
│                │  - Queue ops    │                      │
│                │  - Conflict res │                      │
│                │  - Retry logic  │                      │
│                └────────┬────────┘                      │
└─────────────────────────┼───────────────────────────────┘
                          │
           ───────────────┼─────────────────
                          │ (When online)
                          ▼
           ┌──────────────────────────────┐
           │       Node.js Server         │
           │      (Docker Container)      │
           ├────────────┬─────────────────┤
           │   Fastify  │   PostgreSQL    │
           └────────────┴─────────────────┘
```

### Sync Logic

1. **Drills**: Downloaded on first launch, synced daily via `/api/v1/drills/sync?since={timestamp}`
2. **Sessions**: Queued locally during offline, batch-synced when online
3. **Conflicts**: Server timestamp wins, with client notification
4. **Retries**: Exponential backoff with max 3 attempts

---

## Development Tools

| Tool | Purpose |
|------|---------|
| **VS Code** | Primary IDE with Dart/Flutter extensions |
| **Android Studio** | Android emulator, profiling |
| **Xcode** | iOS simulator, signing |
| **Docker Desktop** | Local container management |
| **Postman/Insomnia** | API testing |
| **pgAdmin/TablePlus** | Database management |
| **Prisma Studio** | Visual database browser |

---

## CI/CD Pipeline

```yaml
# .github/workflows/ci.yml (simplified)
name: CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test-server:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: cd server && npm ci
      - run: cd server && npm run lint
      - run: cd server && npm test

  test-flutter:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
```

---

## Future Considerations (Add When Needed)

| Service | When to Add | Purpose |
|---------|-------------|---------|
| **Redis** | High traffic, session caching | Rate limiting, caching hot data |
| **S3/Cloudflare R2** | Many drill images/videos | Asset storage & CDN |
| **BullMQ** | Background jobs needed | Email, notifications, reports |
| **Elasticsearch** | Large drill library | Full-text search |
| **Sentry** | Production | Error tracking |
| **Grafana/Prometheus** | Production | Monitoring & metrics |

---

**Document Details**
- **Project ID**: bc0ded31-54a9-4f61-91a5-233ceb4d22e3
- **Last Updated**: 2025-12-16
- **Version**: 2.0 (Flutter + Node.js rewrite)
