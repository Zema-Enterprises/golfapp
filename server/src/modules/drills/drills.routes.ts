import type { FastifyInstance, FastifyPluginAsync } from 'fastify';
import { authenticate } from '../auth/auth.middleware.js';
import { requirePermission } from '../auth/permission.middleware.js';
import {
  listDrillsHandler,
  getDrillHandler,
  getCategoriesHandler,
} from './drills.controller.js';

// ============================================
// Drills Routes
// ============================================

const drillsRoutes: FastifyPluginAsync = async (app: FastifyInstance) => {
  // All routes require authentication
  app.addHook('preHandler', authenticate);

  // GET /drills - List drills
  app.route({
    method: 'GET',
    url: '/',
    preHandler: requirePermission('drills:read'),
    schema: {
      tags: ['Drills'],
      summary: 'List drills with filters',
      security: [{ Bearer: [] }],
      querystring: {
        type: 'object',
        properties: {
          ageBand: { type: 'string', enum: ['AGE_4_6', 'AGE_6_8', 'AGE_8_10'] },
          skillCategory: { type: 'string' },
          isPremium: { type: 'boolean' },
          limit: { type: 'integer', minimum: 1, maximum: 50, default: 20 },
          offset: { type: 'integer', minimum: 0, default: 0 },
        },
      },
    },
    handler: listDrillsHandler,
  });

  // GET /drills/categories - Get skill categories
  app.route({
    method: 'GET',
    url: '/categories',
    preHandler: requirePermission('drills:read'),
    schema: {
      tags: ['Drills'],
      summary: 'Get skill categories',
      security: [{ Bearer: [] }],
      querystring: {
        type: 'object',
        properties: {
          ageBand: { type: 'string', enum: ['AGE_4_6', 'AGE_6_8', 'AGE_8_10'] },
        },
      },
    },
    handler: getCategoriesHandler,
  });

  // GET /drills/:id - Get drill details
  app.route({
    method: 'GET',
    url: '/:id',
    preHandler: requirePermission('drills:read'),
    schema: {
      tags: ['Drills'],
      summary: 'Get drill by ID',
      security: [{ Bearer: [] }],
      params: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
        },
      },
    },
    handler: getDrillHandler,
  });
};

export { drillsRoutes };
