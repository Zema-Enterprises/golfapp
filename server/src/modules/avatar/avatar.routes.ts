import type { FastifyInstance, FastifyPluginAsync } from 'fastify';
import { authenticate } from '../auth/auth.middleware.js';
import {
  getShopHandler,
  getAvatarHandler,
  purchaseHandler,
  equipHandler,
  unequipHandler,
} from './avatar.controller.js';

const avatarRoutes: FastifyPluginAsync = async (app: FastifyInstance) => {
  app.addHook('preHandler', authenticate);

  app.route({
    method: 'GET',
    url: '/shop',
    schema: { tags: ['Avatar'], summary: 'Get shop items', security: [{ Bearer: [] }] },
    handler: getShopHandler,
  });

  app.route({
    method: 'GET',
    url: '/:childId',
    schema: { tags: ['Avatar'], summary: 'Get child avatar', security: [{ Bearer: [] }] },
    handler: getAvatarHandler,
  });

  app.route({
    method: 'POST',
    url: '/:childId/purchase',
    schema: { tags: ['Avatar'], summary: 'Purchase item', security: [{ Bearer: [] }] },
    handler: purchaseHandler,
  });

  app.route({
    method: 'POST',
    url: '/:childId/equip',
    schema: { tags: ['Avatar'], summary: 'Equip item', security: [{ Bearer: [] }] },
    handler: equipHandler,
  });

  app.route({
    method: 'DELETE',
    url: '/:childId/equip/:category',
    schema: { tags: ['Avatar'], summary: 'Unequip item', security: [{ Bearer: [] }] },
    handler: unequipHandler,
  });
};

export { avatarRoutes };
