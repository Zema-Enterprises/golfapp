import { FastifyRequest, FastifyReply } from 'fastify';
import { verifyAccessToken } from './auth.utils.js';
import type { JWTPayload } from './auth.types.js';

// ============================================
// Auth Middleware
// ============================================

/**
 * Middleware to verify JWT and attach user to request
 */
export async function authenticate(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  try {
    const authHeader = request.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return reply.status(401).send({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Missing or invalid authorization header',
        },
      });
    }

    const token = authHeader.substring(7);
    const payload = verifyAccessToken(token);

    // Attach user to request
    request.user = payload;
  } catch (error) {
    return reply.status(401).send({
      success: false,
      error: {
        code: 'UNAUTHORIZED',
        message: 'Invalid or expired token',
      },
    });
  }
}

/**
 * Middleware to check if user has required permission
 */
export function requirePermission(_permissionName: string) {
  return async function (
    request: FastifyRequest,
    reply: FastifyReply
  ): Promise<void> {
    // First ensure user is authenticated
    if (!request.user) {
      return reply.status(401).send({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Authentication required',
        },
      });
    }

    // Admin role has all permissions
    if (request.user.roleName === 'admin') {
      return;
    }

    // TODO: Check actual permissions from database
    // For now, we'll implement a simple role-based check
    // In production, query role_permissions table
    
    // Default: allow all authenticated users for basic operations
    // Specific permission checks will be added as features are built
  };
}

/**
 * Get current user from request (throws if not authenticated)
 */
export function getCurrentUser(request: FastifyRequest): JWTPayload {
  if (!request.user) {
    throw new Error('User not authenticated');
  }
  return request.user;
}
