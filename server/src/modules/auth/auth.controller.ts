import { FastifyRequest, FastifyReply } from 'fastify';
import { ZodError } from 'zod';
import { authService } from './auth.service.js';
import { getCurrentUser } from './auth.middleware.js';
import {
  registerSchema,
  loginSchema,
  refreshSchema,
  changePasswordSchema,
  updateProfileSchema,
} from './auth.schema.js';

// ============================================
// Auth Controller
// ============================================

/**
 * POST /auth/register
 */
export async function registerHandler(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  try {
    const input = registerSchema.parse(request.body);
    const result = await authService.register(input);

    reply.status(201).send({
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
          message: 'Validation failed',
          details: error.flatten().fieldErrors,
        },
      });
    }

    const message = error instanceof Error ? error.message : 'Registration failed';
    const status = message.includes('already exists') ? 409 : 400;

    reply.status(status).send({
      success: false,
      error: { code: 'REGISTRATION_FAILED', message },
    });
  }
}

/**
 * POST /auth/login
 */
export async function loginHandler(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  try {
    const input = loginSchema.parse(request.body);
    const result = await authService.login(input);

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
          message: 'Validation failed',
          details: error.flatten().fieldErrors,
        },
      });
    }

    const message = error instanceof Error ? error.message : 'Login failed';
    reply.status(401).send({
      success: false,
      error: { code: 'LOGIN_FAILED', message },
    });
  }
}

/**
 * POST /auth/refresh
 */
export async function refreshHandler(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  try {
    const input = refreshSchema.parse(request.body);
    const tokens = await authService.refreshToken(input.refreshToken);

    reply.send({
      success: true,
      data: { tokens },
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

    const message = error instanceof Error ? error.message : 'Token refresh failed';
    reply.status(401).send({
      success: false,
      error: { code: 'REFRESH_FAILED', message },
    });
  }
}

/**
 * GET /auth/me
 */
export async function getMeHandler(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  try {
    const { userId } = getCurrentUser(request);
    const user = await authService.getCurrentUser(userId);

    reply.send({
      success: true,
      data: { user },
      meta: { timestamp: new Date().toISOString() },
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Failed to get user';
    reply.status(404).send({
      success: false,
      error: { code: 'USER_NOT_FOUND', message },
    });
  }
}

/**
 * PATCH /auth/me
 */
export async function updateMeHandler(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  try {
    const { userId } = getCurrentUser(request);
    const input = updateProfileSchema.parse(request.body);
    const user = await authService.updateProfile(userId, input);

    reply.send({
      success: true,
      data: { user },
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

    const message = error instanceof Error ? error.message : 'Update failed';
    reply.status(400).send({
      success: false,
      error: { code: 'UPDATE_FAILED', message },
    });
  }
}

/**
 * POST /auth/change-password
 */
export async function changePasswordHandler(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  try {
    const { userId } = getCurrentUser(request);
    const input = changePasswordSchema.parse(request.body);
    await authService.changePassword(userId, input);

    reply.send({
      success: true,
      data: { message: 'Password changed successfully' },
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

    const message = error instanceof Error ? error.message : 'Password change failed';
    reply.status(400).send({
      success: false,
      error: { code: 'PASSWORD_CHANGE_FAILED', message },
    });
  }
}

/**
 * POST /auth/logout
 */
export async function logoutHandler(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  try {
    const input = refreshSchema.parse(request.body);
    await authService.logout(input.refreshToken);

    reply.send({
      success: true,
      data: { message: 'Logged out successfully' },
      meta: { timestamp: new Date().toISOString() },
    });
  } catch (error) {
    // Always return success for logout (security best practice)
    reply.send({
      success: true,
      data: { message: 'Logged out successfully' },
      meta: { timestamp: new Date().toISOString() },
    });
  }
}
