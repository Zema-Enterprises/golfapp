import { prisma } from '../../config/database.js';
import type {
  GenerateSessionInput,
  ListSessionsQuery,
  CompleteDrillBody,
} from './sessions.schema.js';
import type { Session, SessionDrill, SessionStatus } from '@prisma/client';

// Constants
const STARS_PER_DRILL = 2;

// Duration to drill count mapping
const DURATION_TO_DRILL_COUNT: Record<string, number> = {
  '10': 2, // 10 min → 2 drills
  '15': 3, // 15 min → 3 drills
  '20': 4, // 20 min → 4 drills
};

// ============================================
// Sessions Service
// ============================================

export interface SessionDrillResponse {
  id: string;
  order: number;
  completed: boolean;
  starsEarned: number;
  verifiedAt: Date | null;
  drill: {
    id: string;
    title: string;
    skillCategory: string;
    durationMinutes: number;
  };
}

export interface SessionResponse {
  id: string;
  childId: string;
  status: SessionStatus;
  totalStarsEarned: number;
  startedAt: Date;
  completedAt: Date | null;
  drills: SessionDrillResponse[];
}

export interface SessionListResponse {
  sessions: SessionResponse[];
  total: number;
  limit: number;
  offset: number;
}

export class SessionsService {
  /**
   * Generate a new practice session for a child
   */
  async generate(parentId: string, input: GenerateSessionInput): Promise<SessionResponse> {
    // Verify child belongs to parent
    const child = await prisma.child.findFirst({
      where: { id: input.childId, parentId },
    });

    if (!child) {
      throw new Error('Child not found');
    }

    // Calculate drill count based on duration
    const drillCount = DURATION_TO_DRILL_COUNT[input.durationMinutes] || 3;

    // Get random drills for child's age band (shuffle for variety)
    const allDrills = await prisma.drill.findMany({
      where: { ageBand: child.ageBand },
    });

    if (allDrills.length === 0) {
      throw new Error('No drills available for this age band');
    }

    // Shuffle and take required number
    const shuffled = allDrills.sort(() => Math.random() - 0.5);
    const selectedDrills = shuffled.slice(0, Math.min(drillCount, shuffled.length));

    // Create session with drills
    const session = await prisma.session.create({
      data: {
        childId: input.childId,
        drills: {
          create: selectedDrills.map((drill, index) => ({
            drillId: drill.id,
            order: index + 1,
          })),
        },
      },
      include: {
        drills: {
          include: { drill: true },
          orderBy: { order: 'asc' },
        },
      },
    });

    return this.formatSession(session);
  }

  /**
   * List sessions with filters
   */
  async list(parentId: string, query: ListSessionsQuery): Promise<SessionListResponse> {
    // Build where clause
    const where: {
      child: { parentId: string };
      childId?: string;
      status?: SessionStatus;
    } = {
      child: { parentId },
    };

    if (query.childId) where.childId = query.childId;
    if (query.status) where.status = query.status;

    const [sessions, total] = await Promise.all([
      prisma.session.findMany({
        where,
        take: query.limit,
        skip: query.offset,
        orderBy: { startedAt: 'desc' },
        include: {
          drills: {
            include: { drill: true },
            orderBy: { order: 'asc' },
          },
        },
      }),
      prisma.session.count({ where }),
    ]);

    return {
      sessions: sessions.map((s) => this.formatSession(s)),
      total,
      limit: query.limit,
      offset: query.offset,
    };
  }

  /**
   * Get single session by ID
   */
  async findOne(parentId: string, sessionId: string): Promise<SessionResponse | null> {
    const session = await prisma.session.findFirst({
      where: {
        id: sessionId,
        child: { parentId },
      },
      include: {
        drills: {
          include: { drill: true },
          orderBy: { order: 'asc' },
        },
      },
    });

    return session ? this.formatSession(session) : null;
  }

  /**
   * Complete a drill in a session (after parent PIN verification)
   */
  async completeDrill(
    parentId: string,
    sessionId: string,
    sessionDrillId: string,
    _body: CompleteDrillBody
  ): Promise<SessionResponse> {
    // Verify session belongs to parent's child
    const session = await prisma.session.findFirst({
      where: {
        id: sessionId,
        child: { parentId },
        status: 'IN_PROGRESS',
      },
      include: {
        drills: {
          include: { drill: true },
          orderBy: { order: 'asc' },
        },
      },
    });

    if (!session) {
      throw new Error('Session not found or already completed');
    }

    // Find the drill in session
    const sessionDrill = session.drills.find((d) => d.id === sessionDrillId);
    if (!sessionDrill) {
      throw new Error('Drill not found in session');
    }

    if (sessionDrill.completed) {
      throw new Error('Drill already completed');
    }

    // Use fixed stars per drill (ignoring body.starsEarned)
    const starsEarned = STARS_PER_DRILL;

    // Update drill as completed
    await prisma.sessionDrill.update({
      where: { id: sessionDrillId },
      data: {
        completed: true,
        starsEarned,
        verifiedAt: new Date(),
      },
    });

    // Update session total stars
    await prisma.session.update({
      where: { id: sessionId },
      data: {
        totalStarsEarned: { increment: starsEarned },
      },
    });

    // Refetch session
    const updatedSession = await prisma.session.findUnique({
      where: { id: sessionId },
      include: {
        drills: {
          include: { drill: true },
          orderBy: { order: 'asc' },
        },
      },
    });

    return this.formatSession(updatedSession!);
  }

  /**
   * Complete entire session
   */
  async complete(parentId: string, sessionId: string): Promise<SessionResponse> {
    const session = await prisma.session.findFirst({
      where: {
        id: sessionId,
        child: { parentId },
        status: 'IN_PROGRESS',
      },
      include: {
        drills: true,
        child: true,
      },
    });

    if (!session) {
      throw new Error('Session not found or already completed');
    }

    // Update session status
    const completedSession = await prisma.session.update({
      where: { id: sessionId },
      data: {
        status: 'COMPLETED',
        completedAt: new Date(),
      },
      include: {
        drills: {
          include: { drill: true },
          orderBy: { order: 'asc' },
        },
      },
    });

    // Update child's stars (both lifetime total and spendable balance)
    await prisma.child.update({
      where: { id: session.childId },
      data: {
        totalStars: { increment: session.totalStarsEarned },
        availableStars: { increment: session.totalStarsEarned },
      },
    });

    return this.formatSession(completedSession);
  }

  // ============================================
  // Private Helpers
  // ============================================

  private formatSession(
    session: Session & {
      drills: (SessionDrill & {
        drill: { id: string; title: string; skillCategory: string; durationMinutes: number };
      })[];
    }
  ): SessionResponse {
    return {
      id: session.id,
      childId: session.childId,
      status: session.status,
      totalStarsEarned: session.totalStarsEarned,
      startedAt: session.startedAt,
      completedAt: session.completedAt,
      drills: session.drills.map((d) => ({
        id: d.id,
        order: d.order,
        completed: d.completed,
        starsEarned: d.starsEarned,
        verifiedAt: d.verifiedAt,
        drill: {
          id: d.drill.id,
          title: d.drill.title,
          skillCategory: d.drill.skillCategory,
          durationMinutes: d.drill.durationMinutes,
        },
      })),
    };
  }
}

// Export singleton
export const sessionsService = new SessionsService();
