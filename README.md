# Junior Golf Playbook

A mobile-first practice app for junior golfers, designed to make golf training fun and engaging.

## Quick Start

### Prerequisites

- Docker & Docker Compose
- Node.js 22+ (for local development without Docker)
- Flutter SDK (for mobile app development)

### Start Development Environment

```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f api

# Stop services
docker compose down
```

### Access Points

| Service | URL | Description |
|---------|-----|-------------|
| API Server | http://localhost:8100 | Backend REST API |
| Health Check | http://localhost:8100/health | Service status |
| Prisma Studio | http://localhost:8102 | Database UI |

## Project Structure

```
GolfApp/
├── .dev/                 # Development tracking (agent-friendly)
├── documentation/        # Project documentation
├── server/              # Node.js backend (Fastify + Prisma)
├── mobile/              # Flutter mobile app
└── docker-compose.yml   # Development environment
```

## Documentation

- [Tech Stack](./documentation/tech_stack_document.md)
- [Backend Structure](./documentation/backend_structure_document.md)
- [Frontend Guidelines](./documentation/frontend_guidelines_document.md)
- [Project Requirements](./documentation/project_requirements_document.md)

## Development

See [.dev/INSTRUCTIONS.md](./.dev/INSTRUCTIONS.md) for development workflow.

## Port Allocation

| Port | Service |
|------|---------|
| 8100 | API Server |
| 8101 | PostgreSQL |
| 8102 | Prisma Studio |
| 8103 | Flutter Web |
