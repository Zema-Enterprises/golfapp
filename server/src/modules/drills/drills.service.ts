import { prisma } from '../../config/database.js';
import type { ListDrillsQuery } from './drills.schema.js';
import type { AgeBand, Drill } from '@prisma/client';

// ============================================
// Drills Service
// ============================================

export interface DrillResponse {
  id: string;
  title: string;
  ageBand: AgeBand;
  skillCategory: string;
  durationMinutes: number;
  setup: string;
  childAction: string;
  parentCue: string;
  commonMistakes: string;
  successCriteria: string;
  imageUrl: string | null;
  videoUrl: string | null;
  isPremium: boolean;
}

export interface DrillListResponse {
  drills: DrillResponse[];
  total: number;
  limit: number;
  offset: number;
}

export class DrillsService {
  /**
   * List drills with filters
   */
  async list(query: ListDrillsQuery): Promise<DrillListResponse> {
    const where: {
      ageBand?: AgeBand;
      skillCategory?: string;
      isPremium?: boolean;
    } = {};

    if (query.ageBand) where.ageBand = query.ageBand;
    if (query.skillCategory) where.skillCategory = query.skillCategory;
    if (query.isPremium !== undefined) where.isPremium = query.isPremium;

    const [drills, total] = await Promise.all([
      prisma.drill.findMany({
        where,
        take: query.limit,
        skip: query.offset,
        orderBy: [{ skillCategory: 'asc' }, { title: 'asc' }],
      }),
      prisma.drill.count({ where }),
    ]);

    return {
      drills: drills.map((d) => this.formatDrill(d)),
      total,
      limit: query.limit,
      offset: query.offset,
    };
  }

  /**
   * Get single drill by ID
   */
  async findOne(id: string): Promise<DrillResponse | null> {
    const drill = await prisma.drill.findUnique({
      where: { id },
    });

    return drill ? this.formatDrill(drill) : null;
  }

  /**
   * Get drills by age band (for session generation)
   */
  async getByAgeBand(ageBand: AgeBand, limit = 3): Promise<DrillResponse[]> {
    const drills = await prisma.drill.findMany({
      where: { ageBand },
      take: limit,
      orderBy: { title: 'asc' },
    });

    return drills.map((d) => this.formatDrill(d));
  }

  /**
   * Get skill categories for an age band
   */
  async getSkillCategories(ageBand?: AgeBand): Promise<string[]> {
    const where = ageBand ? { ageBand } : {};
    
    const categories = await prisma.drill.findMany({
      where,
      select: { skillCategory: true },
      distinct: ['skillCategory'],
      orderBy: { skillCategory: 'asc' },
    });

    return categories.map((c) => c.skillCategory);
  }

  // ============================================
  // Private Helpers
  // ============================================

  private formatDrill(drill: Drill): DrillResponse {
    return {
      id: drill.id,
      title: drill.title,
      ageBand: drill.ageBand,
      skillCategory: drill.skillCategory,
      durationMinutes: drill.durationMinutes,
      setup: drill.setup,
      childAction: drill.childAction,
      parentCue: drill.parentCue,
      commonMistakes: drill.commonMistakes,
      successCriteria: drill.successCriteria,
      imageUrl: drill.imageUrl,
      videoUrl: drill.videoUrl,
      isPremium: drill.isPremium,
    };
  }
}

// Export singleton
export const drillsService = new DrillsService();
