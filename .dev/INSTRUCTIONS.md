# Agent Development Instructions

## Project: Junior Golf Playbook

This document provides instructions for AI agents working on this codebase.

---

## Quick Reference

| Action | Command/Location |
|--------|------------------|
| Start backend | `docker compose up -d` |
| View logs | `docker compose logs -f api` |
| Run migrations | `cd server && npx prisma migrate dev` |
| Database UI | `cd server && npx prisma studio` (port 8102) |
| Run tests | `cd server && npm test` |

---

## How to Pick Up a Task

1. **Check current status** in `PROGRESS.md`
2. **Find available task** in the appropriate area:
   - Backend: `.dev/backend/tasks.md`
   - Frontend: `.dev/frontend/tasks.md`
3. **Mark task as in-progress** by changing `[ ]` to `[/]`
4. **Update `PROGRESS.md`** with what you're working on
5. **Complete the work**
6. **Mark task complete** by changing `[/]` to `[x]`
7. **Document any learnings** in `.dev/general/learnings.md`

---

## Task Status Legend

| Symbol | Meaning |
|--------|---------|
| `[ ]` | Not started |
| `[/]` | In progress |
| `[x]` | Completed |
| `[!]` | Blocked (add note) |

---

## Commit Guidelines

- One logical change per commit
- Format: `<type>(<scope>): <description>`
- Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
- Examples:
  - `feat(auth): add login endpoint`
  - `fix(sessions): correct star calculation`
  - `docs(api): update endpoint documentation`

---

## Port Allocation

| Port | Service |
|------|---------|
| 8100 | API Server (Fastify) |
| 8101 | PostgreSQL |
| 8102 | Prisma Studio |
| 8103 | Flutter Web Dev |
| 8104-8105 | Reserved |

---

## Architecture Summary

### Backend (server/)
- **Framework**: Fastify + TypeScript
- **ORM**: Prisma with PostgreSQL
- **Structure**: Modular with controllers, services, schemas

### Frontend (mobile/)
- **Framework**: Flutter + Dart
- **State**: Riverpod
- **Navigation**: GoRouter
- **Local DB**: Drift (SQLite)

## Important Notes

### ⚠️ PRIMARY RULES - Frontend Testing (Must Follow)

1. **Browser testing is REQUIRED** - Test all frontend features in the browser at the end of implementation
2. **Testing scenarios documentation** - Create and maintain `.dev/frontend/testing/<feature>_testing.md` for each feature
3. **Keep testing docs up-to-date** - Update testing scenarios whenever feature changes

### Testing Workflow

1. After implementing a frontend feature:
   - Create testing scenarios doc in `.dev/frontend/testing/`
   - Start Flutter web with `cd mobile && flutter run -d chrome --web-port=8103`
   - Execute all test scenarios in browser
   - Document test results in the testing scenarios file

---

### ⚠️ PRIMARY RULES - Backend TDD (Must Follow)

1. **TDD approach** - Always write tests before implementing backend features
2. **Run tests after every change** - Ensure all tests pass before committing
3. **Test coverage target** - Aim for >80% coverage

### Backend Testing Workflow

1. **Before implementing a feature:**
   - Write failing test first in `server/tests/<module>.test.ts`
   - Run `npm test` to verify it fails for the right reason

2. **After implementing:**
   - Run `npm test` to verify all tests pass
   - Run `npm run test:coverage` for coverage report

3. **Test commands (inside Docker):**

| Command | Description |
|---------|-------------|
| `docker compose exec api npm test` | Run all tests |
| `docker compose exec api npm run test:watch` | Watch mode |
| `docker compose exec api npm run test:coverage` | Coverage report |
| `docker compose exec api npm test -- auth.test.ts` | Single file |

### General Notes

1. **Never commit secrets** - use `.env` files (gitignored)
2. **Run linters before commits** - `npm run lint` / `flutter analyze`
3. **Check existing docs** in `/documentation` for business logic
4. **Pending questions** are in `/documentation/clarification_questions.md`
