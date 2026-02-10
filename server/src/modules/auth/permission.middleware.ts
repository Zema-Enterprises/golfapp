import { FastifyRequest, FastifyReply } from 'fastify';
import { prisma } from '../../config/database.js';

// ============================================
// Permission Middleware
// ============================================

/**
 * Middleware to check if user has required permission
 * Usage: preHandler: requirePermission('children:read')
 */
export function requirePermission(permissionName: string) {
  return async function (
    request: FastifyRequest,
    reply: FastifyReply
  ): Promise<void> {
    // Ensure user is authenticated
    if (!request.user) {
      return reply.status(401).send({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Authentication required',
        },
      });
    }

    // Admin role bypasses all permission checks
    if (request.user.roleName === 'admin') {
      return;
    }

    // Check if user's role has the required permission
    const rolePermission = await prisma.rolePermission.findFirst({
      where: {
        roleId: request.user.roleId,
        permission: {
          name: permissionName,
        },
      },
    });

    if (!rolePermission) {
      return reply.status(403).send({
        success: false,
        error: {
          code: 'FORBIDDEN',
          message: `Permission '${permissionName}' required`,
        },
      });
    }
  };
}

/**
 * Check multiple permissions (user must have ALL)
 */
export function requireAllPermissions(permissionNames: string[]) {
  return async function (
    request: FastifyRequest,
    reply: FastifyReply
  ): Promise<void> {
    if (!request.user) {
      return reply.status(401).send({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Authentication required',
        },
      });
    }

    if (request.user.roleName === 'admin') {
      return;
    }

    const rolePermissions = await prisma.rolePermission.findMany({
      where: {
        roleId: request.user.roleId,
        permission: {
          name: { in: permissionNames },
        },
      },
      include: {
        permission: true,
      },
    });

    const grantedPermissions = rolePermissions.map((rp: { permission: { name: string } }) => rp.permission.name);
    const missingPermissions = permissionNames.filter(
      (p) => !grantedPermissions.includes(p)
    );

    if (missingPermissions.length > 0) {
      return reply.status(403).send({
        success: false,
        error: {
          code: 'FORBIDDEN',
          message: `Missing permissions: ${missingPermissions.join(', ')}`,
        },
      });
    }
  };
}

/**
 * Check multiple permissions (user must have ANY)
 */
export function requireAnyPermission(permissionNames: string[]) {
  return async function (
    request: FastifyRequest,
    reply: FastifyReply
  ): Promise<void> {
    if (!request.user) {
      return reply.status(401).send({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Authentication required',
        },
      });
    }

    if (request.user.roleName === 'admin') {
      return;
    }

    const rolePermission = await prisma.rolePermission.findFirst({
      where: {
        roleId: request.user.roleId,
        permission: {
          name: { in: permissionNames },
        },
      },
    });

    if (!rolePermission) {
      return reply.status(403).send({
        success: false,
        error: {
          code: 'FORBIDDEN',
          message: `One of these permissions required: ${permissionNames.join(', ')}`,
        },
      });
    }
  };
}
