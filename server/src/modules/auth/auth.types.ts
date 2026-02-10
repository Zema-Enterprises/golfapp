// Auth Types - Self-contained for reusability

// ============================================
// Auth Types
// ============================================

export interface AuthUser {
  id: string;
  email: string;
  isActive: boolean;
  isVerified: boolean;
  role: {
    id: string;
    name: string;
  };
  parent?: {
    id: string;
    hasPin: boolean;
  } | null;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

export interface AuthResponse {
  user: AuthUser;
  tokens: AuthTokens;
}

export interface JWTPayload {
  userId: string;
  email: string;
  roleId: string;
  roleName: string;
  iat?: number;
  exp?: number;
}

// ============================================
// Permission Types
// ============================================

export type PermissionName =
  | 'children:read'
  | 'children:write'
  | 'children:delete'
  | 'drills:read'
  | 'drills:write'
  | 'sessions:read'
  | 'sessions:write'
  | 'settings:read'
  | 'settings:write'
  | 'admin:all';

// ============================================
// Request Context
// ============================================

declare module 'fastify' {
  interface FastifyRequest {
    user?: JWTPayload;
  }
}
