import type { FastifyInstance, FastifyPluginAsync } from 'fastify';
import { authenticate } from '../auth/auth.middleware.js';
import { getSettingsHandler, updateSettingsHandler } from './settings.controller.js';

const settingsRoutes: FastifyPluginAsync = async (app: FastifyInstance) => {
  app.addHook('preHandler', authenticate);

  app.route({
    method: 'GET',
    url: '/',
    schema: {
      tags: ['Settings'],
      summary: 'Get user settings',
      security: [{ Bearer: [] }],
    },
    handler: getSettingsHandler,
  });

  app.route({
    method: 'PATCH',
    url: '/',
    schema: {
      tags: ['Settings'],
      summary: 'Update user settings',
      security: [{ Bearer: [] }],
      body: {
        type: 'object',
        properties: {
          notificationsEnabled: { type: 'boolean' },
          dailyReminderTime: { type: 'string', nullable: true },
          soundEnabled: { type: 'boolean' },
          theme: { type: 'string', enum: ['light', 'dark', 'system'] },
          language: { type: 'string', enum: ['en', 'es', 'fr', 'de'] },
          streakGoal: { type: 'string', enum: ['DAILY', 'FIVE_PER_WEEK', 'THREE_PER_WEEK', 'TWO_PER_WEEK'] },
        },
      },
    },
    handler: updateSettingsHandler,
  });
};

export { settingsRoutes };
