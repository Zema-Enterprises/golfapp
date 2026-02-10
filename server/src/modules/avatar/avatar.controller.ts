import { FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import { avatarService } from './avatar.service.js';
import { prisma } from '../../config/database.js';

// Schemas
const childIdSchema = z.object({ childId: z.string().uuid() });
const itemIdSchema = z.object({ itemId: z.string().min(1) });
const categorySchema = z.object({ category: z.string().optional() });

async function getParentId(userId: string): Promise<string | null> {
  const parent = await prisma.parent.findUnique({
    where: { userId },
    select: { id: true },
  });
  return parent?.id || null;
}

/**
 * GET /avatar/shop - Get all items
 */
export async function getShopHandler(
  request: FastifyRequest<{ Querystring: { category?: string } }>,
  reply: FastifyReply
): Promise<void> {
  const { category } = categorySchema.parse(request.query);
  const items = await avatarService.getShop(category);

  reply.send({
    success: true,
    data: { items },
    meta: { timestamp: new Date().toISOString(), count: items.length },
  });
}

/**
 * GET /avatar/:childId - Get child's avatar
 */
export async function getAvatarHandler(
  request: FastifyRequest<{ Params: { childId: string } }>,
  reply: FastifyReply
): Promise<void> {
  const { childId } = childIdSchema.parse(request.params);
  const parentId = await getParentId(request.user!.userId);

  if (!parentId) {
    return reply.status(404).send({ success: false, error: { code: 'NOT_FOUND', message: 'Parent not found' } });
  }

  const avatar = await avatarService.getChildAvatar(parentId, childId);
  if (!avatar) {
    return reply.status(404).send({ success: false, error: { code: 'NOT_FOUND', message: 'Child not found' } });
  }

  reply.send({ success: true, data: { avatar }, meta: { timestamp: new Date().toISOString() } });
}

/**
 * POST /avatar/:childId/purchase - Purchase item
 */
export async function purchaseHandler(
  request: FastifyRequest<{ Params: { childId: string }; Body: { itemId: string } }>,
  reply: FastifyReply
): Promise<void> {
  try {
    const { childId } = childIdSchema.parse(request.params);
    const { itemId } = itemIdSchema.parse(request.body);
    const parentId = await getParentId(request.user!.userId);

    if (!parentId) {
      return reply.status(404).send({ success: false, error: { code: 'NOT_FOUND', message: 'Parent not found' } });
    }

    await avatarService.purchaseItem(parentId, childId, itemId);

    reply.send({ success: true, data: { message: 'Item purchased' }, meta: { timestamp: new Date().toISOString() } });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Purchase failed';
    reply.status(400).send({ success: false, error: { code: 'PURCHASE_ERROR', message } });
  }
}

/**
 * POST /avatar/:childId/equip - Equip item
 */
export async function equipHandler(
  request: FastifyRequest<{ Params: { childId: string }; Body: { itemId: string } }>,
  reply: FastifyReply
): Promise<void> {
  try {
    const { childId } = childIdSchema.parse(request.params);
    const { itemId } = itemIdSchema.parse(request.body);
    const parentId = await getParentId(request.user!.userId);

    if (!parentId) {
      return reply.status(404).send({ success: false, error: { code: 'NOT_FOUND', message: 'Parent not found' } });
    }

    const avatarState = await avatarService.equipItem(parentId, childId, itemId);

    reply.send({ success: true, data: { avatarState }, meta: { timestamp: new Date().toISOString() } });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Equip failed';
    reply.status(400).send({ success: false, error: { code: 'EQUIP_ERROR', message } });
  }
}

/**
 * DELETE /avatar/:childId/equip/:category - Unequip
 */
export async function unequipHandler(
  request: FastifyRequest<{ Params: { childId: string; category: string } }>,
  reply: FastifyReply
): Promise<void> {
  try {
    const { childId } = childIdSchema.parse({ childId: request.params.childId });
    const parentId = await getParentId(request.user!.userId);

    if (!parentId) {
      return reply.status(404).send({ success: false, error: { code: 'NOT_FOUND', message: 'Parent not found' } });
    }

    const avatarState = await avatarService.unequipItem(parentId, childId, request.params.category);

    reply.send({ success: true, data: { avatarState }, meta: { timestamp: new Date().toISOString() } });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unequip failed';
    reply.status(400).send({ success: false, error: { code: 'UNEQUIP_ERROR', message } });
  }
}
