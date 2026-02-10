import type { FastifyInstance, FastifyPluginAsync } from 'fastify';
import { authenticate } from '../auth/auth.middleware.js';
import { requirePermission } from '../auth/permission.middleware.js';
import {
  generateSessionHandler,
  listSessionsHandler,
  getSessionHandler,
  completeDrillHandler,
  completeSessionHandler,
} from './sessions.controller.js';

// ============================================
// Sessions Routes
// ============================================

const sessionsRoutes: FastifyPluginAsync = async (app: FastifyInstance) => {
  // All routes require authentication
  app.addHook('preHandler', authenticate);

  // POST /sessions - Generate new session
  app.route({
    method: 'POST',
    url: '/',
    preHandler: requirePermission('sessions:write'),
    schema: {
      tags: ['Sessions'],
      summary: 'Generate a practice session',
      security: [{ Bearer: [] }],
      body: {
        type: 'object',
        required: ['childId'],
        properties: {
          childId: { type: 'string', format: 'uuid' },
          durationMinutes: { type: 'string', enum: ['10', '15', '20'], default: '15' },
        },
      },
    },
    handler: generateSessionHandler,
  });

  // GET /sessions - List sessions
  app.route({
    method: 'GET',
    url: '/',
    preHandler: requirePermission('sessions:read'),
    schema: {
      tags: ['Sessions'],
      summary: 'List practice sessions',
      security: [{ Bearer: [] }],
      querystring: {
        type: 'object',
        properties: {
          childId: { type: 'string', format: 'uuid' },
          status: { type: 'string', enum: ['IN_PROGRESS', 'COMPLETED', 'ABANDONED'] },
          limit: { type: 'integer', minimum: 1, maximum: 50, default: 20 },
          offset: { type: 'integer', minimum: 0, default: 0 },
        },
      },
    },
    handler: listSessionsHandler,
  });

  // GET /sessions/:id - Get session details
  app.route({
    method: 'GET',
    url: '/:id',
    preHandler: requirePermission('sessions:read'),
    schema: {
      tags: ['Sessions'],
      summary: 'Get session by ID',
      security: [{ Bearer: [] }],
      params: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
        },
      },
    },
    handler: getSessionHandler,
  });

  // PATCH /sessions/:id/drills/:drillId - Complete a drill
  app.route({
    method: 'PATCH',
    url: '/:id/drills/:drillId',
    preHandler: requirePermission('sessions:write'),
    schema: {
      tags: ['Sessions'],
      summary: 'Complete a drill in session',
      security: [{ Bearer: [] }],
      params: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          drillId: { type: 'string', format: 'uuid' },
        },
      },
      body: {
        type: 'object',
        properties: {
          starsEarned: { type: 'integer', minimum: 0, maximum: 3, default: 1 },
        },
      },
    },
    handler: completeDrillHandler,
  });

  // POST /sessions/:id/complete - Complete entire session
  app.route({
    method: 'POST',
    url: '/:id/complete',
    preHandler: requirePermission('sessions:write'),
    schema: {
      tags: ['Sessions'],
      summary: 'Complete practice session',
      security: [{ Bearer: [] }],
      params: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
        },
      },
    },
    handler: completeSessionHandler,
  });
};

export { sessionsRoutes };
