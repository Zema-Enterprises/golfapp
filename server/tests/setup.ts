import { beforeAll, afterAll, afterEach } from 'vitest';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Global setup - runs once before all tests
beforeAll(async () => {
  await prisma.$connect();
});

// Cleanup after each test
afterEach(async () => {
  // Use raw SQL for cleanup to avoid model name issues
  await prisma.$executeRaw`DELETE FROM session_drills`;
  await prisma.$executeRaw`DELETE FROM sessions`;
  await prisma.$executeRaw`DELETE FROM child_avatar_items`;
  await prisma.$executeRaw`DELETE FROM streaks`;
  await prisma.$executeRaw`DELETE FROM children`;
  await prisma.$executeRaw`DELETE FROM parents`;
  await prisma.$executeRaw`DELETE FROM refresh_tokens`;
  await prisma.$executeRaw`DELETE FROM user_settings`;
  await prisma.$executeRaw`DELETE FROM users`;
});

// Global teardown - runs once after all tests
afterAll(async () => {
  await prisma.$disconnect();
});
