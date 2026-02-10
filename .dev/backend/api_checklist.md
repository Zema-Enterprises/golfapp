# API Endpoint Implementation Checklist

## Authentication `/api/v1/auth`

| Endpoint | Method | Status | Notes |
|----------|--------|--------|-------|
| `/register` | POST | [ ] | Parent signup |
| `/login` | POST | [ ] | Returns JWT |
| `/refresh` | POST | [ ] | Token refresh |
| `/forgot-password` | POST | [ ] | Initiate reset |
| `/reset-password` | POST | [ ] | Complete reset |
| `/verify-pin` | POST | [ ] | Drill verification |
| `/change-pin` | PATCH | [ ] | Update PIN |

## Children `/api/v1/children`

| Endpoint | Method | Status | Notes |
|----------|--------|--------|-------|
| `/` | GET | [ ] | List parent's children |
| `/` | POST | [ ] | Add child |
| `/:id` | GET | [ ] | Get child details |
| `/:id` | PATCH | [ ] | Update child |
| `/:id` | DELETE | [ ] | Soft delete |

## Drills `/api/v1/drills`

| Endpoint | Method | Status | Notes |
|----------|--------|--------|-------|
| `/` | GET | [ ] | List with filters |
| `/:id` | GET | [ ] | Get details |
| `/sync` | GET | [ ] | Delta sync |

## Sessions `/api/v1/sessions`

| Endpoint | Method | Status | Notes |
|----------|--------|--------|-------|
| `/generate` | POST | [ ] | Generate for child |
| `/:id` | GET | [ ] | Get session |
| `/:id` | PATCH | [ ] | Update status |
| `/:id/drills/:drillId/complete` | POST | [ ] | Complete drill |

## Progress `/api/v1/children/:id`

| Endpoint | Method | Status | Notes |
|----------|--------|--------|-------|
| `/progress` | GET | [ ] | Stats, stars, streaks |
| `/avatar` | GET | [ ] | Avatar state |
| `/avatar/equip` | POST | [ ] | Equip item |
| `/sessions` | GET | [ ] | Session history |

## Misc

| Endpoint | Method | Status | Notes |
|----------|--------|--------|-------|
| `/api/v1/sync` | GET | [ ] | Full sync payload |
| `/api/v1/avatar-items` | GET | [ ] | All available items |
| `/api/v1/users/me` | GET | [ ] | Current user |
| `/api/v1/users/settings` | PATCH | [ ] | Update settings |
| `/api/v1/users` | DELETE | [ ] | Delete account |
| `/health` | GET | [ ] | Health check |
