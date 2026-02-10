import { prisma } from '../../config/database.js';
import type { CreateChildInput, UpdateChildInput } from './children.schema.js';
import type { AgeBand, Prisma, SkillLevel } from '@prisma/client';

// ============================================
// Children Service
// ============================================

export interface ChildResponse {
  id: string;
  name: string;
  ageBand: AgeBand;
  skillLevel: SkillLevel;
  totalStars: number;
  availableStars: number;
  avatarState: unknown;
  createdAt: Date;
  updatedAt: Date;
}

export class ChildrenService {
  /**
   * Create a new child for a parent
   */
  async create(parentId: string, input: CreateChildInput): Promise<ChildResponse> {
    const child = await prisma.child.create({
      data: {
        parentId,
        name: input.name,
        ageBand: input.ageBand,
        skillLevel: input.skillLevel || 'BEGINNER',
        avatarState: (input.avatarState ?? {}) as Prisma.InputJsonValue,
      },
    });

    return this.formatChild(child);
  }

  /**
   * List all children for a parent
   */
  async findByParent(parentId: string): Promise<ChildResponse[]> {
    const children = await prisma.child.findMany({
      where: { parentId },
      orderBy: { createdAt: 'asc' },
    });

    return children.map((c) => this.formatChild(c));
  }

  /**
   * Get a single child by ID (must belong to parent)
   */
  async findOne(parentId: string, childId: string): Promise<ChildResponse | null> {
    const child = await prisma.child.findFirst({
      where: {
        id: childId,
        parentId,
      },
    });

    return child ? this.formatChild(child) : null;
  }

  /**
   * Update a child
   */
  async update(
    parentId: string,
    childId: string,
    input: UpdateChildInput
  ): Promise<ChildResponse | null> {
    // Verify ownership
    const existing = await prisma.child.findFirst({
      where: { id: childId, parentId },
    });

    if (!existing) {
      return null;
    }

    const child = await prisma.child.update({
      where: { id: childId },
      data: input,
    });

    return this.formatChild(child);
  }

  /**
   * Delete a child
   */
  async delete(parentId: string, childId: string): Promise<boolean> {
    // Verify ownership
    const existing = await prisma.child.findFirst({
      where: { id: childId, parentId },
    });

    if (!existing) {
      return false;
    }

    await prisma.child.delete({
      where: { id: childId },
    });

    return true;
  }

  /**
   * Get child with stats
   */
  async getWithStats(parentId: string, childId: string) {
    const child = await prisma.child.findFirst({
      where: { id: childId, parentId },
      include: {
        streak: true,
        sessions: {
          take: 5,
          orderBy: { startedAt: 'desc' },
          select: {
            id: true,
            status: true,
            totalStarsEarned: true,
            startedAt: true,
            completedAt: true,
          },
        },
        _count: {
          select: { sessions: true },
        },
      },
    });

    if (!child) return null;

    return {
      ...this.formatChild(child),
      streak: child.streak,
      recentSessions: child.sessions,
      totalSessions: child._count.sessions,
    };
  }

  // ============================================
  // Private Helpers
  // ============================================

  private formatChild(child: {
    id: string;
    name: string;
    ageBand: AgeBand;
    skillLevel: SkillLevel;
    totalStars: number;
    availableStars: number;
    avatarState: unknown;
    createdAt: Date;
    updatedAt: Date;
  }): ChildResponse {
    return {
      id: child.id,
      name: child.name,
      ageBand: child.ageBand,
      skillLevel: child.skillLevel,
      totalStars: child.totalStars,
      availableStars: child.availableStars,
      avatarState: child.avatarState,
      createdAt: child.createdAt,
      updatedAt: child.updatedAt,
    };
  }
}

// Export singleton
export const childrenService = new ChildrenService();
