import { FastifyRequest, FastifyReply } from 'fastify';
import { ZodError } from 'zod';
import { sessionsService } from './sessions.service.js';
import {
  generateSessionSchema,
  sessionIdSchema,
  completeDrillSchema,
  completeDrillBodySchema,
  listSessionsQuerySchema,
} from './sessions.schema.js';
import { prisma } from '../../config/database.js';

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
// Sessions Controller
// ============================================

/**
 * POST /sessions - Generate new session
 */
export async function generateSessionHandler(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  try {
    const parentId = await getParentId(request.user!.userId);
    if (!parentId) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Parent profile not found' },
      });
    }

    const input = generateSessionSchema.parse(request.body);
    const session = await sessionsService.generate(parentId, input);

    reply.status(201).send({
      success: true,
      data: { session },
      meta: { timestamp: new Date().toISOString() },
    });
  } catch (error) {
    if (error instanceof ZodError) {
      return reply.status(400).send({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Validation failed',
          details: error.flatten().fieldErrors,
        },
      });
    }

    const message = error instanceof Error ? error.message : 'Failed to generate session';
    reply.status(400).send({
      success: false,
      error: { code: 'SESSION_ERROR', message },
    });
  }
}

/**
 * GET /sessions - List sessions
 */
export async function listSessionsHandler(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  try {
    const parentId = await getParentId(request.user!.userId);
    if (!parentId) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Parent profile not found' },
      });
    }

    const query = listSessionsQuerySchema.parse(request.query);
    const result = await sessionsService.list(parentId, query);

    reply.send({
      success: true,
      data: result,
      meta: { timestamp: new Date().toISOString() },
    });
  } catch (error) {
    if (error instanceof ZodError) {
      return reply.status(400).send({
        success: false,
        error: { code: 'VALIDATION_ERROR', message: 'Invalid query parameters' },
      });
    }
    throw error;
  }
}

/**
 * GET /sessions/:id - Get session details
 */
export async function getSessionHandler(
  request: FastifyRequest<{ Params: { id: string } }>,
  reply: FastifyReply
): Promise<void> {
  try {
    const { id } = sessionIdSchema.parse(request.params);
    const parentId = await getParentId(request.user!.userId);

    if (!parentId) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Parent profile not found' },
      });
    }

    const session = await sessionsService.findOne(parentId, id);

    if (!session) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Session not found' },
      });
    }

    reply.send({
      success: true,
      data: { session },
      meta: { timestamp: new Date().toISOString() },
    });
  } catch (error) {
    if (error instanceof ZodError) {
      return reply.status(400).send({
        success: false,
        error: { code: 'VALIDATION_ERROR', message: 'Invalid session ID' },
      });
    }
    throw error;
  }
}

/**
 * PATCH /sessions/:id/drills/:drillId - Complete a drill
 */
export async function completeDrillHandler(
  request: FastifyRequest<{ Params: { id: string; drillId: string } }>,
  reply: FastifyReply
): Promise<void> {
  try {
    const params = completeDrillSchema.parse(request.params);
    const body = completeDrillBodySchema.parse(request.body);
    const parentId = await getParentId(request.user!.userId);

    if (!parentId) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Parent profile not found' },
      });
    }

    const session = await sessionsService.completeDrill(
      parentId,
      params.id,
      params.drillId,
      body
    );

    reply.send({
      success: true,
      data: { session },
      meta: { timestamp: new Date().toISOString() },
    });
  } catch (error) {
    if (error instanceof ZodError) {
      return reply.status(400).send({
        success: false,
        error: { code: 'VALIDATION_ERROR', message: 'Validation failed' },
      });
    }

    const message = error instanceof Error ? error.message : 'Failed to complete drill';
    reply.status(400).send({
      success: false,
      error: { code: 'DRILL_ERROR', message },
    });
  }
}

/**
 * POST /sessions/:id/complete - Complete entire session
 */
export async function completeSessionHandler(
  request: FastifyRequest<{ Params: { id: string } }>,
  reply: FastifyReply
): Promise<void> {
  try {
    const { id } = sessionIdSchema.parse(request.params);
    const parentId = await getParentId(request.user!.userId);

    if (!parentId) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Parent profile not found' },
      });
    }

    const session = await sessionsService.complete(parentId, id);

    reply.send({
      success: true,
      data: { session },
      meta: { timestamp: new Date().toISOString() },
    });
  } catch (error) {
    if (error instanceof ZodError) {
      return reply.status(400).send({
        success: false,
        error: { code: 'VALIDATION_ERROR', message: 'Invalid session ID' },
      });
    }

    const message = error instanceof Error ? error.message : 'Failed to complete session';
    reply.status(400).send({
      success: false,
      error: { code: 'SESSION_ERROR', message },
    });
  }
}
