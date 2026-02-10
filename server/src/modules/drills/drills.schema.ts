import { z } from 'zod';

// ============================================
// Drills Validation Schemas
// ============================================

export const ageBandEnum = z.enum(['AGE_4_6', 'AGE_6_8', 'AGE_8_10']);

export const listDrillsQuerySchema = z.object({
  ageBand: ageBandEnum.optional(),
  skillCategory: z.string().optional(),
  isPremium: z.coerce.boolean().optional(),
  limit: z.coerce.number().min(1).max(50).default(20),
  offset: z.coerce.number().min(0).default(0),
});

export const drillIdSchema = z.object({
  id: z.string().uuid('Invalid drill ID'),
});

// ============================================
// Type Exports
// ============================================

export type ListDrillsQuery = z.infer<typeof listDrillsQuerySchema>;
export type DrillIdParam = z.infer<typeof drillIdSchema>;
