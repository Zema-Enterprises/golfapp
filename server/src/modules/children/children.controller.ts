import { FastifyRequest, FastifyReply } from 'fastify';
import { ZodError } from 'zod';
import { childrenService } from './children.service.js';
import { createChildSchema, updateChildSchema, childIdSchema } from './children.schema.js';
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
// Children Controller
// ============================================

/**
 * POST /children - Create child
 */
export async function createChildHandler(
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

    const input = createChildSchema.parse(request.body);
    const child = await childrenService.create(parentId, input);

    reply.status(201).send({
      success: true,
      data: { child },
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
    throw error;
  }
}

/**
 * GET /children - List children
 */
export async function listChildrenHandler(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  const parentId = await getParentId(request.user!.userId);
  if (!parentId) {
    return reply.status(404).send({
      success: false,
      error: { code: 'NOT_FOUND', message: 'Parent profile not found' },
    });
  }

  const children = await childrenService.findByParent(parentId);

  reply.send({
    success: true,
    data: { children },
    meta: { timestamp: new Date().toISOString(), count: children.length },
  });
}

/**
 * GET /children/:id - Get single child
 */
export async function getChildHandler(
  request: FastifyRequest<{ Params: { id: string } }>,
  reply: FastifyReply
): Promise<void> {
  try {
    const { id } = childIdSchema.parse(request.params);
    const parentId = await getParentId(request.user!.userId);
    
    if (!parentId) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Parent profile not found' },
      });
    }

    const child = await childrenService.getWithStats(parentId, id);

    if (!child) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Child not found' },
      });
    }

    reply.send({
      success: true,
      data: { child },
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
 * PATCH /children/:id - Update child
 */
export async function updateChildHandler(
  request: FastifyRequest<{ Params: { id: string } }>,
  reply: FastifyReply
): Promise<void> {
  try {
    const { id } = childIdSchema.parse(request.params);
    const parentId = await getParentId(request.user!.userId);
    
    if (!parentId) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Parent profile not found' },
      });
    }

    const input = updateChildSchema.parse(request.body);
    const child = await childrenService.update(parentId, id, input);

    if (!child) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Child not found' },
      });
    }

    reply.send({
      success: true,
      data: { child },
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
    throw error;
  }
}

/**
 * DELETE /children/:id - Delete child
 */
export async function deleteChildHandler(
  request: FastifyRequest<{ Params: { id: string } }>,
  reply: FastifyReply
): Promise<void> {
  try {
    const { id } = childIdSchema.parse(request.params);
    const parentId = await getParentId(request.user!.userId);
    
    if (!parentId) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Parent profile not found' },
      });
    }

    const deleted = await childrenService.delete(parentId, id);

    if (!deleted) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Child not found' },
      });
    }

    reply.status(204).send();
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
