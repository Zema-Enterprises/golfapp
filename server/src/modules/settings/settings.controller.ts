import { FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import { settingsService } from './settings.service.js';

const updateSettingsSchema = z.object({
  notificationsEnabled: z.boolean().optional(),
  dailyReminderTime: z.string().nullable().optional(),
  soundEnabled: z.boolean().optional(),
  theme: z.enum(['light', 'dark', 'system']).optional(),
  language: z.enum(['en', 'es', 'fr', 'de']).optional(),
  streakGoal: z.enum(['DAILY', 'FIVE_PER_WEEK', 'THREE_PER_WEEK', 'TWO_PER_WEEK']).optional(),
});

/**
 * GET /settings - Get current user settings
 */
export async function getSettingsHandler(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  const settings = await settingsService.getSettings(request.user!.userId);

  reply.send({
    success: true,
    data: { settings },
    meta: { timestamp: new Date().toISOString() },
  });
}

/**
 * PATCH /settings - Update settings
 */
export async function updateSettingsHandler(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  try {
    const input = updateSettingsSchema.parse(request.body);
    const settings = await settingsService.updateSettings(request.user!.userId, input);

    reply.send({
      success: true,
      data: { settings },
      meta: { timestamp: new Date().toISOString() },
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return reply.status(400).send({
        success: false,
        error: { code: 'VALIDATION_ERROR', message: 'Invalid settings', details: error.flatten().fieldErrors },
      });
    }
    throw error;
  }
}
