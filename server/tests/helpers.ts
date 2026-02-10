import { buildApp } from '../src/app.js';
import { FastifyInstance } from 'fastify';
import { PrismaClient } from '@prisma/client';
import { hashPassword, generateAccessToken } from '../src/modules/auth/auth.utils.js';

const prisma = new PrismaClient();

// ============================================
// Test App Helper
// ============================================

let app: FastifyInstance | null = null;

export async function getTestApp(): Promise<FastifyInstance> {
  if (!app) {
    app = await buildApp();
    await app.ready();
  }
  return app;
}

export async function closeTestApp(): Promise<void> {
  if (app) {
    await app.close();
    app = null;
  }
}

// ============================================
// Auth Helpers
// ============================================

export interface TestUser {
  user: {
    id: string;
    email: string;
    roleId: string;
  };
  parent: {
    id: string;
  };
  accessToken: string;
}

export async function createTestUser(email = 'test@example.com'): Promise<TestUser> {
  // Get or create parent role
  let role = await prisma.role.findUnique({ where: { name: 'parent' } });
  if (!role) {
    role = await prisma.role.create({
      data: { name: 'parent', description: 'Parent user' },
    });
  }

  const passwordHash = await hashPassword('TestPass123');

  const user = await prisma.user.create({
    data: {
      email,
      passwordHash,
      roleId: role.id,
      isActive: true,
      isVerified: true,
    },
  });

  const parent = await prisma.parent.create({
    data: { user: { connect: { id: user.id } } },
  });

  const accessToken = generateAccessToken({
    userId: user.id,
    email: user.email,
    roleId: role.id,
    roleName: role.name,
  });

  return {
    user: { id: user.id, email: user.email, roleId: role.id },
    parent: { id: parent.id },
    accessToken,
  };
}

// ============================================
// Data Helpers
// ============================================

export async function createTestChild(parentId: string, name = 'Test Child') {
  return prisma.child.create({
    data: {
      parentId,
      name,
      ageBand: 'AGE_4_6',
      skillLevel: 'BEGINNER',
    },
  });
}

export async function createTestDrills() {
  const drills = [
    {
      title: 'Test Drill 1',
      ageBand: 'AGE_4_6' as const,
      skillCategory: 'Putting',
      setup: 'Setup',
      childAction: 'Action',
      parentCue: 'Cue',
      commonMistakes: 'Mistakes',
      successCriteria: 'Success',
    },
    {
      title: 'Test Drill 2',
      ageBand: 'AGE_4_6' as const,
      skillCategory: 'Chipping',
      setup: 'Setup',
      childAction: 'Action',
      parentCue: 'Cue',
      commonMistakes: 'Mistakes',
      successCriteria: 'Success',
    },
  ];

  for (const drill of drills) {
    await prisma.drill.create({ data: drill });
  }
}

// ============================================
// Request Helpers
// ============================================

export function authHeader(token: string) {
  return { Authorization: `Bearer ${token}` };
}
