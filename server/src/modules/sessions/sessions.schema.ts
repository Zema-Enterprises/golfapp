import { z } from 'zod';

// ============================================
// Sessions Validation Schemas
// ============================================

export const generateSessionSchema = z.object({
  childId: z.string().uuid('Invalid child ID'),
  durationMinutes: z.enum(['10', '15', '20']).default('15'),
});

export const sessionIdSchema = z.object({
  id: z.string().uuid('Invalid session ID'),
});

export const completeDrillSchema = z.object({
  id: z.string().uuid('Invalid session ID'),
  drillId: z.string().uuid('Invalid drill ID'),
});

export const completeDrillBodySchema = z.object({
  starsEarned: z.number().min(0).max(3).default(1),
});

export const listSessionsQuerySchema = z.object({
  childId: z.string().uuid().optional(),
  status: z.enum(['IN_PROGRESS', 'COMPLETED', 'ABANDONED']).optional(),
  limit: z.coerce.number().min(1).max(50).default(20),
  offset: z.coerce.number().min(0).default(0),
});

// ============================================
// Type Exports
// ============================================

export type GenerateSessionInput = z.infer<typeof generateSessionSchema>;
export type SessionIdParam = z.infer<typeof sessionIdSchema>;
export type CompleteDrillParams = z.infer<typeof completeDrillSchema>;
export type CompleteDrillBody = z.infer<typeof completeDrillBodySchema>;
export type ListSessionsQuery = z.infer<typeof listSessionsQuerySchema>;
