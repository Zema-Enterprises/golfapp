# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Junior Golf Playbook - A mobile-first practice app for junior golfers (ages 4-10). Full-stack application with Flutter mobile frontend and Node.js/Fastify backend.

## Tech Stack

**Backend**: Node.js 22+, Fastify 5.1, TypeScript 5.7, Prisma ORM, PostgreSQL 16, Vitest
**Frontend**: Flutter/Dart with Riverpod state management, GoRouter navigation, Drift (SQLite) local database, Dio HTTP client

## Development Commands

### Backend (`server/`)
```bash
npm run dev              # Start dev server with hot reload
npm run build            # Compile TypeScript
npm test                 # Run tests (vitest)
npm test:watch           # Watch mode
npm run lint             # ESLint check
npm run lint:fix         # Fix lint issues
npm run format           # Prettier format
npm run db:migrate       # Run Prisma migrations
npm run db:studio        # Prisma Studio GUI (port 8102)
npm run db:seed          # Seed database
```

### Frontend (`mobile/`)
```bash
flutter pub get                           # Install dependencies
flutter run -d chrome --web-port=8103     # Run web dev server
flutter analyze                           # Dart linting
flutter build web                         # Production build
```

### Docker (Full Stack)
```bash
docker compose up -d          # Start all services
docker compose logs -f api    # View API logs
docker compose down           # Stop services
```

## Port Allocation

| Port | Service |
|------|---------|
| 8100 | Fastify API |
| 8101 | PostgreSQL |
| 8102 | Prisma Studio |
| 8103 | Flutter Web |

## Architecture

### Backend Structure (`server/src/`)
- **Modular architecture**: Each feature in `modules/` with controller, service, routes, schema pattern
- `modules/` - Feature modules (auth, children, drills, sessions, progress, avatar, settings, health)
- `config/` - Environment and database configuration
- `middleware/` - Error handling middleware
- `types/` - TypeScript type definitions
- Path aliases: `@/*`, `@config/*`, `@modules/*`, `@middleware/*`, `@utils/*`, `@types/*`

### Frontend Structure (`mobile/lib/`)
- **Feature-first architecture**: Features separated by domain
- `features/` - Feature modules (auth, dashboard, drills, sessions, etc.)
- `core/config/` - Constants, environment
- `core/network/` - Dio client setup with interceptors
- `core/database/` - Drift local database
- `core/services/` - Business logic services
- `shared/` - Shared widgets, theme, providers
- `routing/` - GoRouter configuration

## Code Standards

### Backend (TypeScript)
- Strict mode enabled
- ESLint flat config with Prettier (100 char lines, semicolons, single quotes)
- Explicit return types on functions
- No unused variables (prefix with `_` if intentionally unused)
- Prefer `const` over `let`, no `var`

### Frontend (Dart)
- Null safety enforced
- Code generation with build_runner, Freezed, JSON serializable

## Testing Requirements

- **Backend**: TDD approach - write tests before implementation, >80% coverage target
- **Frontend**: Browser testing for UI features, document test scenarios in `.dev/frontend/testing/`
- Always run tests after changes

## Development Tracking

- `.dev/PROGRESS.md` - Overall progress tracking
- `.dev/backend/` - Backend task tracking
- `.dev/frontend/` - Frontend task tracking
- `documentation/` - Project documentation (requirements, architecture, flow)

## Environment Variables

Required in `server/.env`:
- `DATABASE_URL` - PostgreSQL connection string
- `JWT_SECRET` - Min 32 characters
- `JWT_EXPIRES_IN` - Default: 15m
- `CORS_ORIGINS` - Comma-separated allowed origins
- `API_PORT` - Default: 8100

## Key Features

- JWT authentication with Parent PIN verification for drill completion
- Gamification: stars, rewards, avatar customization
- Offline-first mobile with sync capability
- Structured practice sessions for parents to guide children
