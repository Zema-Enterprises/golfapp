import { prisma } from '../../config/database.js';

// ============================================
// Progress Service
// ============================================

// Streak goal types
export type StreakGoal = 'DAILY' | 'FIVE_PER_WEEK' | 'THREE_PER_WEEK' | 'TWO_PER_WEEK';

const STREAK_GOAL_TARGETS: Record<StreakGoal, number> = {
  DAILY: 7,
  FIVE_PER_WEEK: 5,
  THREE_PER_WEEK: 3,
  TWO_PER_WEEK: 2,
};

export interface ChildStatsResponse {
  childId: string;
  name: string;
  totalStars: number;
  availableStars: number;
  totalSessions: number;
  completedSessions: number;
  averageStarsPerSession: number;
  skillProgress: Record<string, number>;
}

export interface StreakResponse {
  childId: string;
  currentStreak: number;
  longestStreak: number;
  lastSessionDate: Date | null;
  weeklySessionCount: number;
  weeklyGoal: number;
  goalMet: boolean;
  weekStartDate: Date;
}

export class ProgressService {
  /**
   * Get child's overall stats
   */
  async getStats(parentId: string, childId: string): Promise<ChildStatsResponse | null> {
    // Verify child belongs to parent
    const child = await prisma.child.findFirst({
      where: { id: childId, parentId },
      include: {
        sessions: {
          include: {
            drills: {
              include: { drill: true },
            },
          },
        },
      },
    });

    if (!child) return null;

    const completedSessions = child.sessions.filter((s) => s.status === 'COMPLETED');
    const totalStarsFromSessions = completedSessions.reduce(
      (sum, s) => sum + s.totalStarsEarned,
      0
    );

    // Calculate skill progress (stars per category)
    const skillProgress: Record<string, number> = {};
    for (const session of completedSessions) {
      for (const sd of session.drills) {
        if (sd.completed) {
          const category = sd.drill.skillCategory;
          skillProgress[category] = (skillProgress[category] || 0) + sd.starsEarned;
        }
      }
    }

    return {
      childId: child.id,
      name: child.name,
      totalStars: child.totalStars,
      availableStars: child.availableStars,
      totalSessions: child.sessions.length,
      completedSessions: completedSessions.length,
      averageStarsPerSession:
        completedSessions.length > 0
          ? Math.round((totalStarsFromSessions / completedSessions.length) * 10) / 10
          : 0,
      skillProgress,
    };
  }

  /**
   * Get child's streak info
   */
  async getStreak(parentId: string, childId: string): Promise<StreakResponse | null> {
    // Verify child belongs to parent and get parent settings
    const child = await prisma.child.findFirst({
      where: { id: childId, parentId },
      include: {
        streak: true,
        parent: true,
      },
    });

    if (!child) return null;

    // Get parent's streak goal from settings (default: THREE_PER_WEEK)
    const parentSettings = (child.parent.settings as Record<string, unknown>) || {};
    const streakGoal = (parentSettings.streakGoal as StreakGoal) || 'THREE_PER_WEEK';
    const weeklyGoal = STREAK_GOAL_TARGETS[streakGoal];

    // Create streak if it doesn't exist
    let streak = child.streak;
    if (!streak) {
      streak = await prisma.streak.create({
        data: {
          childId: child.id,
          weekStartDate: this.getWeekStart(),
        },
      });
    }

    return {
      childId: child.id,
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
      lastSessionDate: streak.lastSessionDate,
      weeklySessionCount: streak.weeklySessionCount,
      weeklyGoal,
      goalMet: streak.weeklySessionCount >= weeklyGoal,
      weekStartDate: streak.weekStartDate,
    };
  }

  /**
   * Update streak after completing a session
   * Streak is based on "weeks in a row meeting the parent's configured goal"
   */
  async updateStreak(parentId: string, childId: string): Promise<StreakResponse> {
    // Verify child belongs to parent and get parent settings
    const child = await prisma.child.findFirst({
      where: { id: childId, parentId },
      include: {
        streak: true,
        parent: true,
      },
    });

    if (!child) {
      throw new Error('Child not found');
    }

    // Get parent's streak goal
    const parentSettings = (child.parent.settings as Record<string, unknown>) || {};
    const streakGoal = (parentSettings.streakGoal as StreakGoal) || 'THREE_PER_WEEK';
    const weeklyGoal = STREAK_GOAL_TARGETS[streakGoal];

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const weekStart = this.getWeekStart();

    let streak = child.streak;

    if (!streak) {
      // Create new streak
      streak = await prisma.streak.create({
        data: {
          childId: child.id,
          currentStreak: 0,
          longestStreak: 0,
          lastSessionDate: today,
          weeklySessionCount: 1,
          weekStartDate: weekStart,
        },
      });
    } else {
      let newStreak = streak.currentStreak;
      let newWeeklyCount = streak.weeklySessionCount;

      // Check if we're in a new week
      const isNewWeek = streak.weekStartDate < weekStart;

      if (isNewWeek) {
        // Check if previous week met the goal
        const previousWeekMetGoal = streak.weeklySessionCount >= weeklyGoal;

        if (previousWeekMetGoal) {
          // Increment streak (weeks in a row meeting goal)
          newStreak++;
        } else {
          // Previous week didn't meet goal, reset streak
          newStreak = 0;
        }

        // Reset weekly count for new week
        newWeeklyCount = 1;
      } else {
        // Same week, just increment count
        newWeeklyCount++;

        // Check if this session completes the weekly goal
        if (newWeeklyCount === weeklyGoal && streak.weeklySessionCount < weeklyGoal) {
          // Just met the goal this session, increment streak
          newStreak++;
        }
      }

      const newLongest = Math.max(streak.longestStreak, newStreak);

      streak = await prisma.streak.update({
        where: { id: streak.id },
        data: {
          currentStreak: newStreak,
          longestStreak: newLongest,
          lastSessionDate: today,
          weeklySessionCount: newWeeklyCount,
          weekStartDate: weekStart,
        },
      });
    }

    return {
      childId: child.id,
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
      lastSessionDate: streak.lastSessionDate,
      weeklySessionCount: streak.weeklySessionCount,
      weeklyGoal,
      goalMet: streak.weeklySessionCount >= weeklyGoal,
      weekStartDate: streak.weekStartDate,
    };
  }

  // ============================================
  // Private Helpers
  // ============================================

  private getWeekStart(): Date {
    const now = new Date();
    const dayOfWeek = now.getDay();
    const diff = now.getDate() - dayOfWeek + (dayOfWeek === 0 ? -6 : 1);
    const monday = new Date(now.setDate(diff));
    monday.setHours(0, 0, 0, 0);
    return monday;
  }
}

// Export singleton
export const progressService = new ProgressService();
