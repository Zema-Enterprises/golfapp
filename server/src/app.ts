import Fastify, { FastifyInstance } from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import sensible from '@fastify/sensible';
import rateLimit from '@fastify/rate-limit';
import swagger from '@fastify/swagger';
import swaggerUi from '@fastify/swagger-ui';

import { env } from './config/env.js';
import { errorHandler } from './middleware/error.middleware.js';
import { healthRoutes } from './modules/health/health.routes.js';
import { authRoutes } from './modules/auth/auth.routes.js';
import { childrenRoutes } from './modules/children/children.routes.js';
import { drillsRoutes } from './modules/drills/drills.routes.js';
import { sessionsRoutes } from './modules/sessions/sessions.routes.js';
import { progressRoutes } from './modules/progress/progress.routes.js';
import { avatarRoutes } from './modules/avatar/avatar.routes.js';
import { settingsRoutes } from './modules/settings/settings.routes.js';

export async function buildApp(): Promise<FastifyInstance> {
  const app = Fastify({
    logger: {
      level: env.NODE_ENV === 'development' ? 'info' : 'warn',
      transport:
        env.NODE_ENV === 'development'
          ? {
              target: 'pino-pretty',
              options: {
                translateTime: 'HH:MM:ss Z',
                ignore: 'pid,hostname',
              },
            }
          : undefined,
    },
  });

  // Security
  await app.register(helmet, {
    contentSecurityPolicy: false,
  });

  // CORS
  const corsOrigins = env.CORS_ORIGINS?.split(',') || ['http://localhost:8103'];
  await app.register(cors, {
    origin: corsOrigins,
    credentials: true,
  });

  // Rate limiting
  await app.register(rateLimit, {
    max: 100,
    timeWindow: '1 minute',
  });

  // Utilities
  await app.register(sensible);

  // API Documentation
  await app.register(swagger, {
    openapi: {
      info: {
        title: 'Junior Golf Playbook API',
        description: 'API for the Junior Golf Playbook mobile application',
        version: '1.0.0',
      },
      servers: [
        { url: `http://localhost:${env.API_PORT}`, description: 'Development' },
      ],
      tags: [
        { name: 'Health', description: 'Health check endpoints' },
        { name: 'Auth', description: 'Authentication endpoints' },
        { name: 'Children', description: 'Child management endpoints' },
        { name: 'Drills', description: 'Drill management endpoints' },
        { name: 'Sessions', description: 'Session management endpoints' },
        { name: 'Progress', description: 'Progress and streaks endpoints' },
        { name: 'Avatar', description: 'Avatar customization endpoints' },
        { name: 'Settings', description: 'User preferences endpoints' },
      ],
    },
  });

  await app.register(swaggerUi, {
    routePrefix: '/docs',
    uiConfig: {
      docExpansion: 'list',
      deepLinking: true,
    },
  });

  // Error handler
  app.setErrorHandler(errorHandler);

  // Routes
  await app.register(healthRoutes, { prefix: '/health' });

  // API v1 routes
  await app.register(authRoutes, { prefix: '/api/v1/auth' });
  await app.register(childrenRoutes, { prefix: '/api/v1/children' });
  await app.register(drillsRoutes, { prefix: '/api/v1/drills' });
  await app.register(sessionsRoutes, { prefix: '/api/v1/sessions' });
  await app.register(progressRoutes, { prefix: '/api/v1/progress' });
  await app.register(avatarRoutes, { prefix: '/api/v1/avatar' });
  await app.register(settingsRoutes, { prefix: '/api/v1/settings' });

  return app;
}
