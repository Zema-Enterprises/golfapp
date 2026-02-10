import { z } from 'zod';

// ============================================
// Children Validation Schemas
// ============================================

export const ageBandEnum = z.enum(['AGE_4_6', 'AGE_6_8', 'AGE_8_10']);
export const skillLevelEnum = z.enum(['BEGINNER', 'INTERMEDIATE', 'ADVANCED']);

export const createChildSchema = z.object({
  name: z.string().min(1, 'Name is required').max(50, 'Name too long'),
  ageBand: ageBandEnum,
  skillLevel: skillLevelEnum.optional().default('BEGINNER'),
  avatarState: z.record(z.unknown()).optional(),
});

export const updateChildSchema = z.object({
  name: z.string().min(1).max(50).optional(),
  ageBand: ageBandEnum.optional(),
  skillLevel: skillLevelEnum.optional(),
});

export const childIdSchema = z.object({
  id: z.string().uuid('Invalid child ID'),
});

// ============================================
// Type Exports
// ============================================

export type CreateChildInput = z.infer<typeof createChildSchema>;
export type UpdateChildInput = z.infer<typeof updateChildSchema>;
export type ChildIdParam = z.infer<typeof childIdSchema>;
