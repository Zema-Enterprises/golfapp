import { FastifyRequest, FastifyReply } from 'fastify';
import { ZodError } from 'zod';
import { drillsService } from './drills.service.js';
import { listDrillsQuerySchema, drillIdSchema } from './drills.schema.js';

// ============================================
// Drills Controller
// ============================================

/**
 * GET /drills - List drills with filters
 */
export async function listDrillsHandler(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  try {
    const query = listDrillsQuerySchema.parse(request.query);
    const result = await drillsService.list(query);

    reply.send({
      success: true,
      data: result,
      meta: { timestamp: new Date().toISOString() },
    });
  } catch (error) {
    if (error instanceof ZodError) {
      return reply.status(400).send({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid query parameters',
          details: error.flatten().fieldErrors,
        },
      });
    }
    throw error;
  }
}

/**
 * GET /drills/:id - Get drill details
 */
export async function getDrillHandler(
  request: FastifyRequest<{ Params: { id: string } }>,
  reply: FastifyReply
): Promise<void> {
  try {
    const { id } = drillIdSchema.parse(request.params);
    const drill = await drillsService.findOne(id);

    if (!drill) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Drill not found' },
      });
    }

    reply.send({
      success: true,
      data: { drill },
      meta: { timestamp: new Date().toISOString() },
    });
  } catch (error) {
    if (error instanceof ZodError) {
      return reply.status(400).send({
        success: false,
        error: { code: 'VALIDATION_ERROR', message: 'Invalid drill ID' },
      });
    }
    throw error;
  }
}

/**
 * GET /drills/categories - Get skill categories
 */
export async function getCategoriesHandler(
  request: FastifyRequest<{ Querystring: { ageBand?: string } }>,
  reply: FastifyReply
): Promise<void> {
  const ageBand = request.query.ageBand as 'AGE_4_6' | 'AGE_6_8' | 'AGE_8_10' | undefined;
  const categories = await drillsService.getSkillCategories(ageBand);

  reply.send({
    success: true,
    data: { categories },
    meta: { timestamp: new Date().toISOString() },
  });
}
