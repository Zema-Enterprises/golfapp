import { FastifyRequest, FastifyReply } from 'fastify';
import { ZodError } from 'zod';
import { pinService } from './pin.service.js';
import { getCurrentUser } from './auth.middleware.js';
import { pinSchema, verifyPinSchema, changePinSchema } from './auth.schema.js';

// ============================================
// PIN Controller
// ============================================

/**
 * POST /auth/set-pin
 */
export async function setPinHandler(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  try {
    const { userId } = getCurrentUser(request);
    const input = pinSchema.parse(request.body);
    await pinService.setPin(userId, input);

    reply.status(201).send({
      success: true,
      data: { message: 'PIN set successfully' },
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

    const message = error instanceof Error ? error.message : 'Failed to set PIN';
    reply.status(400).send({
      success: false,
      error: { code: 'PIN_ERROR', message },
    });
  }
}

/**
 * POST /auth/verify-pin
 */
export async function verifyPinHandler(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  try {
    const { userId } = getCurrentUser(request);
    const input = verifyPinSchema.parse(request.body);
    await pinService.verifyPin(userId, input);

    reply.send({
      success: true,
      data: { verified: true },
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

    const message = error instanceof Error ? error.message : 'PIN verification failed';
    const status = message.includes('Invalid PIN') ? 401 : 400;
    
    reply.status(status).send({
      success: false,
      error: { code: 'PIN_VERIFICATION_FAILED', message },
    });
  }
}

/**
 * PATCH /auth/change-pin
 */
export async function changePinHandler(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  try {
    const { userId } = getCurrentUser(request);
    const input = changePinSchema.parse(request.body);
    await pinService.changePin(userId, input);

    reply.send({
      success: true,
      data: { message: 'PIN changed successfully' },
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

    const message = error instanceof Error ? error.message : 'Failed to change PIN';
    const status = message.includes('incorrect') ? 401 : 400;
    
    reply.status(status).send({
      success: false,
      error: { code: 'PIN_CHANGE_FAILED', message },
    });
  }
}
