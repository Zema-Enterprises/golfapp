import { FastifyRequest, FastifyReply } from 'fastify';
import { ZodError } from 'zod';
import { z } from 'zod';
import { progressService } from './progress.service.js';
import { prisma } from '../../config/database.js';

// ============================================
// Schemas
// ============================================

const childIdSchema = z.object({
  childId: z.string().uuid('Invalid child ID'),
});

// ============================================
// Helpers
// ============================================

async function getParentId(userId: string): Promise<string | null> {
  const parent = await prisma.parent.findUnique({
    where: { userId },
    select: { id: true },
  });
  return parent?.id || null;
}

// ============================================
// Progress Controller
// ============================================

/**
 * GET /progress/:childId - Get child stats
 */
export async function getStatsHandler(
  request: FastifyRequest<{ Params: { childId: string } }>,
  reply: FastifyReply
): Promise<void> {
  try {
    const { childId } = childIdSchema.parse(request.params);
    const parentId = await getParentId(request.user!.userId);

    if (!parentId) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Parent profile not found' },
      });
    }

    const stats = await progressService.getStats(parentId, childId);

    if (!stats) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Child not found' },
      });
    }

    reply.send({
      success: true,
      data: { stats },
      meta: { timestamp: new Date().toISOString() },
    });
  } catch (error) {
    if (error instanceof ZodError) {
      return reply.status(400).send({
        success: false,
        error: { code: 'VALIDATION_ERROR', message: 'Invalid child ID' },
      });
    }
    throw error;
  }
}

/**
 * GET /progress/:childId/streak - Get streak info
 */
export async function getStreakHandler(
  request: FastifyRequest<{ Params: { childId: string } }>,
  reply: FastifyReply
): Promise<void> {
  try {
    const { childId } = childIdSchema.parse(request.params);
    const parentId = await getParentId(request.user!.userId);

    if (!parentId) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Parent profile not found' },
      });
    }

    const streak = await progressService.getStreak(parentId, childId);

    if (!streak) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Child not found' },
      });
    }

    reply.send({
      success: true,
      data: { streak },
      meta: { timestamp: new Date().toISOString() },
    });
  } catch (error) {
    if (error instanceof ZodError) {
      return reply.status(400).send({
        success: false,
        error: { code: 'VALIDATION_ERROR', message: 'Invalid child ID' },
      });
    }
    throw error;
  }
}

/**
 * POST /progress/:childId/streak - Update streak
 */
export async function updateStreakHandler(
  request: FastifyRequest<{ Params: { childId: string } }>,
  reply: FastifyReply
): Promise<void> {
  try {
    const { childId } = childIdSchema.parse(request.params);
    const parentId = await getParentId(request.user!.userId);

    if (!parentId) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Parent profile not found' },
      });
    }

    const streak = await progressService.updateStreak(parentId, childId);

    reply.send({
      success: true,
      data: { streak },
      meta: { timestamp: new Date().toISOString() },
    });
  } catch (error) {
    if (error instanceof ZodError) {
      return reply.status(400).send({
        success: false,
        error: { code: 'VALIDATION_ERROR', message: 'Invalid child ID' },
      });
    }

    const message = error instanceof Error ? error.message : 'Failed to update streak';
    reply.status(400).send({
      success: false,
      error: { code: 'STREAK_ERROR', message },
    });
  }
}
