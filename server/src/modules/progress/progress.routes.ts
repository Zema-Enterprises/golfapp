import type { FastifyInstance, FastifyPluginAsync } from 'fastify';
import { authenticate } from '../auth/auth.middleware.js';
import { requirePermission } from '../auth/permission.middleware.js';
import {
  getStatsHandler,
  getStreakHandler,
  updateStreakHandler,
} from './progress.controller.js';

// ============================================
// Progress Routes
// ============================================

const progressRoutes: FastifyPluginAsync = async (app: FastifyInstance) => {
  // All routes require authentication
  app.addHook('preHandler', authenticate);

  // GET /progress/:childId - Get child stats
  app.route({
    method: 'GET',
    url: '/:childId',
    preHandler: requirePermission('children:read'),
    schema: {
      tags: ['Progress'],
      summary: 'Get child progress stats',
      security: [{ Bearer: [] }],
      params: {
        type: 'object',
        properties: {
          childId: { type: 'string', format: 'uuid' },
        },
      },
    },
    handler: getStatsHandler,
  });

  // GET /progress/:childId/streak - Get streak info
  app.route({
    method: 'GET',
    url: '/:childId/streak',
    preHandler: requirePermission('children:read'),
    schema: {
      tags: ['Progress'],
      summary: 'Get child streak info',
      security: [{ Bearer: [] }],
      params: {
        type: 'object',
        properties: {
          childId: { type: 'string', format: 'uuid' },
        },
      },
    },
    handler: getStreakHandler,
  });

  // POST /progress/:childId/streak - Update streak
  app.route({
    method: 'POST',
    url: '/:childId/streak',
    preHandler: requirePermission('children:write'),
    schema: {
      tags: ['Progress'],
      summary: 'Update child streak',
      security: [{ Bearer: [] }],
      params: {
        type: 'object',
        properties: {
          childId: { type: 'string', format: 'uuid' },
        },
      },
    },
    handler: updateStreakHandler,
  });
};

export { progressRoutes };
