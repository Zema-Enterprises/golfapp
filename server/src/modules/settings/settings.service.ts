import { prisma } from '../../config/database.js';

// ============================================
// Settings Service
// ============================================

export type StreakGoal = 'DAILY' | 'FIVE_PER_WEEK' | 'THREE_PER_WEEK' | 'TWO_PER_WEEK';

export interface UserSettingsResponse {
  userId: string;
  notificationsEnabled: boolean;
  dailyReminderTime: string | null;
  soundEnabled: boolean;
  theme: string;
  language: string;
  streakGoal: StreakGoal;
}

export interface UpdateSettingsInput {
  notificationsEnabled?: boolean;
  dailyReminderTime?: string | null;
  soundEnabled?: boolean;
  theme?: string;
  language?: string;
  streakGoal?: StreakGoal;
}

export class SettingsService {
  /**
   * Get user settings
   */
  async getSettings(userId: string): Promise<UserSettingsResponse> {
    let settings = await prisma.userSettings.findUnique({
      where: { userId },
    });

    // Create default settings if none exist
    if (!settings) {
      settings = await prisma.userSettings.create({
        data: {
          userId,
          notificationsEnabled: true,
          soundEnabled: true,
          theme: 'light',
          language: 'en',
        },
      });
    }

    // Get streak goal from Parent.settings JSON field
    const parent = await prisma.parent.findUnique({
      where: { userId },
    });
    const parentSettings = (parent?.settings as Record<string, unknown>) || {};
    const streakGoal = (parentSettings.streakGoal as StreakGoal) || 'THREE_PER_WEEK';

    return this.formatSettings(settings, streakGoal);
  }

  /**
   * Update user settings
   */
  async updateSettings(userId: string, input: UpdateSettingsInput): Promise<UserSettingsResponse> {
    // Separate streakGoal from UserSettings fields
    const { streakGoal: newStreakGoal, ...userSettingsInput } = input;

    const settings = await prisma.userSettings.upsert({
      where: { userId },
      update: userSettingsInput,
      create: {
        userId,
        notificationsEnabled: userSettingsInput.notificationsEnabled ?? true,
        dailyReminderTime: userSettingsInput.dailyReminderTime ?? null,
        soundEnabled: userSettingsInput.soundEnabled ?? true,
        theme: userSettingsInput.theme ?? 'light',
        language: userSettingsInput.language ?? 'en',
      },
    });

    // Update streakGoal in Parent.settings JSON if provided
    let streakGoal: StreakGoal = 'THREE_PER_WEEK';
    const parent = await prisma.parent.findUnique({
      where: { userId },
    });

    if (parent) {
      const parentSettings = (parent.settings as Record<string, unknown>) || {};

      if (newStreakGoal) {
        const updatedParentSettings = { ...parentSettings, streakGoal: newStreakGoal };
        await prisma.parent.update({
          where: { userId },
          data: { settings: updatedParentSettings },
        });
        streakGoal = newStreakGoal;
      } else {
        streakGoal = (parentSettings.streakGoal as StreakGoal) || 'THREE_PER_WEEK';
      }
    }

    return this.formatSettings(settings, streakGoal);
  }

  // ============================================
  // Private
  // ============================================

  private formatSettings(
    settings: {
      userId: string;
      notificationsEnabled: boolean;
      dailyReminderTime: string | null;
      soundEnabled: boolean;
      theme: string;
      language: string;
    },
    streakGoal: StreakGoal,
  ): UserSettingsResponse {
    return {
      userId: settings.userId,
      notificationsEnabled: settings.notificationsEnabled,
      dailyReminderTime: settings.dailyReminderTime,
      soundEnabled: settings.soundEnabled,
      theme: settings.theme,
      language: settings.language,
      streakGoal,
    };
  }
}

export const settingsService = new SettingsService();
