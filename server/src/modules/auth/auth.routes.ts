import type { FastifyInstance, FastifyPluginAsync } from 'fastify';
import { authenticate } from './auth.middleware.js';
import {
  registerHandler,
  loginHandler,
  refreshHandler,
  getMeHandler,
  updateMeHandler,
  changePasswordHandler,
  logoutHandler,
} from './auth.controller.js';
import {
  setPinHandler,
  verifyPinHandler,
  changePinHandler,
} from './pin.controller.js';

// ============================================
// Auth Routes
// ============================================

const authRoutes: FastifyPluginAsync = async (app: FastifyInstance) => {
  // Public routes
  app.route({
    method: 'POST',
    url: '/register',
    schema: {
      tags: ['Auth'],
      summary: 'Register a new user',
      body: {
        type: 'object',
        required: ['email', 'password'],
        properties: {
          email: { type: 'string', format: 'email' },
          password: { type: 'string', minLength: 8 },
        },
      },
    },
    handler: registerHandler,
  });

  app.route({
    method: 'POST',
    url: '/login',
    schema: {
      tags: ['Auth'],
      summary: 'Login with email and password',
      body: {
        type: 'object',
        required: ['email', 'password'],
        properties: {
          email: { type: 'string', format: 'email' },
          password: { type: 'string' },
        },
      },
    },
    handler: loginHandler,
  });

  app.route({
    method: 'POST',
    url: '/refresh',
    schema: {
      tags: ['Auth'],
      summary: 'Refresh access token',
      body: {
        type: 'object',
        required: ['refreshToken'],
        properties: {
          refreshToken: { type: 'string' },
        },
      },
    },
    handler: refreshHandler,
  });

  app.route({
    method: 'POST',
    url: '/logout',
    schema: {
      tags: ['Auth'],
      summary: 'Logout and revoke refresh token',
      body: {
        type: 'object',
        required: ['refreshToken'],
        properties: {
          refreshToken: { type: 'string' },
        },
      },
    },
    handler: logoutHandler,
  });

  // Protected routes
  app.route({
    method: 'GET',
    url: '/me',
    preHandler: authenticate,
    schema: {
      tags: ['Auth'],
      summary: 'Get current user',
      security: [{ Bearer: [] }],
    },
    handler: getMeHandler,
  });

  app.route({
    method: 'PATCH',
    url: '/me',
    preHandler: authenticate,
    schema: {
      tags: ['Auth'],
      summary: 'Update current user profile',
      security: [{ Bearer: [] }],
      body: {
        type: 'object',
        properties: {
          email: { type: 'string', format: 'email' },
        },
      },
    },
    handler: updateMeHandler,
  });

  app.route({
    method: 'POST',
    url: '/change-password',
    preHandler: authenticate,
    schema: {
      tags: ['Auth'],
      summary: 'Change password',
      security: [{ Bearer: [] }],
      body: {
        type: 'object',
        required: ['currentPassword', 'newPassword'],
        properties: {
          currentPassword: { type: 'string' },
          newPassword: { type: 'string', minLength: 8 },
        },
      },
    },
    handler: changePasswordHandler,
  });

  // PIN Routes (GolfApp Extension)
  app.route({
    method: 'POST',
    url: '/set-pin',
    preHandler: authenticate,
    schema: {
      tags: ['Auth - PIN'],
      summary: 'Set initial PIN for parent',
      security: [{ Bearer: [] }],
      body: {
        type: 'object',
        required: ['pin'],
        properties: {
          pin: { type: 'string', minLength: 4, maxLength: 4 },
        },
      },
    },
    handler: setPinHandler,
  });

  app.route({
    method: 'POST',
    url: '/verify-pin',
    preHandler: authenticate,
    schema: {
      tags: ['Auth - PIN'],
      summary: 'Verify parent PIN',
      security: [{ Bearer: [] }],
      body: {
        type: 'object',
        required: ['pin'],
        properties: {
          pin: { type: 'string', minLength: 4, maxLength: 4 },
        },
      },
    },
    handler: verifyPinHandler,
  });

  app.route({
    method: 'PATCH',
    url: '/change-pin',
    preHandler: authenticate,
    schema: {
      tags: ['Auth - PIN'],
      summary: 'Change existing PIN',
      security: [{ Bearer: [] }],
      body: {
        type: 'object',
        required: ['currentPin', 'newPin'],
        properties: {
          currentPin: { type: 'string', minLength: 4, maxLength: 4 },
          newPin: { type: 'string', minLength: 4, maxLength: 4 },
        },
      },
    },
    handler: changePinHandler,
  });
};

export { authRoutes };

