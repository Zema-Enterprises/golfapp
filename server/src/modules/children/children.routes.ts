import type { FastifyInstance, FastifyPluginAsync } from 'fastify';
import { authenticate } from '../auth/auth.middleware.js';
import { requirePermission } from '../auth/permission.middleware.js';
import {
  createChildHandler,
  listChildrenHandler,
  getChildHandler,
  updateChildHandler,
  deleteChildHandler,
} from './children.controller.js';

// ============================================
// Children Routes
// ============================================

const childrenRoutes: FastifyPluginAsync = async (app: FastifyInstance) => {
  // All routes require authentication
  app.addHook('preHandler', authenticate);

  // POST /children - Create child
  app.route({
    method: 'POST',
    url: '/',
    preHandler: requirePermission('children:write'),
    schema: {
      tags: ['Children'],
      summary: 'Add a new child',
      security: [{ Bearer: [] }],
      body: {
        type: 'object',
        required: ['name', 'ageBand'],
        properties: {
          name: { type: 'string', minLength: 1, maxLength: 50 },
          ageBand: { type: 'string', enum: ['AGE_4_6', 'AGE_6_8', 'AGE_8_10'] },
          skillLevel: { type: 'string', enum: ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'] },
        },
      },
    },
    handler: createChildHandler,
  });

  // GET /children - List children
  app.route({
    method: 'GET',
    url: '/',
    preHandler: requirePermission('children:read'),
    schema: {
      tags: ['Children'],
      summary: 'List all children',
      security: [{ Bearer: [] }],
    },
    handler: listChildrenHandler,
  });

  // GET /children/:id - Get single child
  app.route({
    method: 'GET',
    url: '/:id',
    preHandler: requirePermission('children:read'),
    schema: {
      tags: ['Children'],
      summary: 'Get child by ID',
      security: [{ Bearer: [] }],
      params: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
        },
      },
    },
    handler: getChildHandler,
  });

  // PATCH /children/:id - Update child
  app.route({
    method: 'PATCH',
    url: '/:id',
    preHandler: requirePermission('children:write'),
    schema: {
      tags: ['Children'],
      summary: 'Update child',
      security: [{ Bearer: [] }],
      params: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
        },
      },
      body: {
        type: 'object',
        properties: {
          name: { type: 'string', minLength: 1, maxLength: 50 },
          ageBand: { type: 'string', enum: ['AGE_4_6', 'AGE_6_8', 'AGE_8_10'] },
          skillLevel: { type: 'string', enum: ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'] },
        },
      },
    },
    handler: updateChildHandler,
  });

  // DELETE /children/:id - Delete child
  app.route({
    method: 'DELETE',
    url: '/:id',
    preHandler: requirePermission('children:delete'),
    schema: {
      tags: ['Children'],
      summary: 'Delete child',
      security: [{ Bearer: [] }],
      params: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
        },
      },
    },
    handler: deleteChildHandler,
  });
};

export { childrenRoutes };
